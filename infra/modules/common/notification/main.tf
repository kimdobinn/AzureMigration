# Azure Notification Module - equivalent to AWS SNS + SES
# Uses Azure Communication Services for email delivery and Service Bus for topic-based messaging

# Data source to get current Azure AD client configuration
data "azuread_client_config" "current" {}

# Local variables for resource naming
locals {
  split_resource_name_prefix             = split("-", var.resource_name_prefix)
  resource_name_prefix_capitalized_parts = [for part in local.split_resource_name_prefix : "${upper(substr(part, 0, 1))}${substr(part, 1, length(part))}"]
  pascal_case_resource_name_prefix       = join("", local.resource_name_prefix_capitalized_parts)
}

# Communication Services for email delivery (equivalent to AWS SES)
resource "azurerm_communication_service" "this" {
  name                = "${var.resource_name_prefix}-comm-svc"
  resource_group_name = var.resource_group_name
  data_location       = "United States" # Required for Communication Services

  tags = var.tags
}

# Email Communication Service Domain (for sending emails)
resource "azurerm_email_communication_service" "this" {
  name                = "${var.resource_name_prefix}-email-svc"
  resource_group_name = var.resource_group_name
  data_location       = "United States" # Required for Email Communication Services

  tags = var.tags
}

# Email Domain for the Communication Service
resource "azurerm_email_communication_service_domain" "this" {
  name              = "${var.resource_name_prefix}-email-domain"
  email_service_id  = azurerm_email_communication_service.this.id
  domain_management = "AzureManaged" # Azure manages the domain

  tags = var.tags
}

# Service Bus Namespace for topic-based messaging (equivalent to AWS SNS)
resource "azurerm_servicebus_namespace" "this" {
  name                = "${var.resource_name_prefix}-sb-ns"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard" # Standard tier supports topics and subscriptions

  tags = var.tags
}

# Service Bus Topic for cloud logging (equivalent to AWS SNS Topic)
resource "azurerm_servicebus_topic" "cloud_log" {
  name         = var.topic_name
  namespace_id = azurerm_servicebus_namespace.this.id

  # Topic configuration
  max_size_in_megabytes = 1024
  default_message_ttl   = "P14D" # 14 days TTL

  # Enable duplicate detection
  duplicate_detection_history_time_window = "PT10M"
}

# Service Bus Subscription for email notifications
resource "azurerm_servicebus_subscription" "email_subscription" {
  name     = "email-notifications"
  topic_id = azurerm_servicebus_topic.cloud_log.id

  # Subscription configuration
  max_delivery_count  = 10
  default_message_ttl = "P14D"
  lock_duration       = "PT1M"

  # Enable dead lettering
  dead_lettering_on_message_expiration      = true
  dead_lettering_on_filter_evaluation_error = true
}

# User Assigned Managed Identity for application access (equivalent to AWS IAM User)
resource "azurerm_user_assigned_identity" "notification_identity" {
  name                = "${var.resource_name_prefix}-notification-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Role assignment for Communication Services access
resource "azurerm_role_assignment" "communication_contributor" {
  scope                = azurerm_communication_service.this.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.notification_identity.principal_id
}

# Role assignment for Service Bus access
resource "azurerm_role_assignment" "servicebus_data_sender" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.notification_identity.principal_id
}

# Role assignment for Service Bus receiver (for processing messages)
resource "azurerm_role_assignment" "servicebus_data_receiver" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azurerm_user_assigned_identity.notification_identity.principal_id
}

# Create a service principal for programmatic access (equivalent to AWS access keys)
resource "azuread_application" "notification_app" {
  display_name = "${var.resource_name_prefix}-notification-app"

  # Required API permissions for Communication Services and Service Bus
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}

# Service Principal for the application
resource "azuread_service_principal" "notification_sp" {
  client_id = azuread_application.notification_app.client_id
}

# Client secret for the service principal (equivalent to AWS secret access key)
resource "azuread_application_password" "notification_secret" {
  application_id = azuread_application.notification_app.id
  display_name   = "notification-service-secret"
  end_date       = timeadd(timestamp(), "8760h") # 1 year from now
}

# Role assignments for the service principal
resource "azurerm_role_assignment" "sp_communication_contributor" {
  scope                = azurerm_communication_service.this.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.notification_sp.object_id
}

resource "azurerm_role_assignment" "sp_servicebus_data_sender" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azuread_service_principal.notification_sp.object_id
}

resource "azurerm_role_assignment" "sp_servicebus_data_receiver" {
  scope                = azurerm_servicebus_namespace.this.id
  role_definition_name = "Azure Service Bus Data Receiver"
  principal_id         = azuread_service_principal.notification_sp.object_id
}

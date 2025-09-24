# Azure Notification Module Outputs - equivalent to AWS SNS + SES outputs

# Region and basic information
output "location" {
  description = "Azure region where notification resources are deployed. Equivalent to AWS region."
  value       = var.location
}

output "resource_group_name" {
  description = "Resource group name where notification resources are deployed."
  value       = var.resource_group_name
}

# Service Principal credentials (equivalent to AWS IAM access keys)
output "client_id" {
  description = "The client ID (application ID) which an application can use to authenticate. Equivalent to AWS access key ID."
  value       = azuread_application.notification_app.client_id
  sensitive   = false
}

output "client_secret" {
  description = "The client secret which an application can use to authenticate. Equivalent to AWS secret access key."
  value       = azuread_application_password.notification_secret.value
  sensitive   = true
}

output "tenant_id" {
  description = "The Azure AD tenant ID required for authentication."
  value       = data.azuread_client_config.current.tenant_id
  sensitive   = false
}

# Communication Services outputs (equivalent to AWS SES)
output "communication_service_name" {
  description = "Name of the Azure Communication Service. Used for email delivery."
  value       = azurerm_communication_service.this.name
}

output "communication_service_connection_string" {
  description = "Connection string for the Azure Communication Service."
  value       = azurerm_communication_service.this.primary_connection_string
  sensitive   = true
}

output "email_service_name" {
  description = "Name of the Azure Email Communication Service."
  value       = azurerm_email_communication_service.this.name
}

output "email_domain_name" {
  description = "The email domain name for sending emails."
  value       = azurerm_email_communication_service_domain.this.name
}

# Service Bus outputs (equivalent to AWS SNS)
output "servicebus_namespace_name" {
  description = "Name of the Service Bus namespace. Used for topic-based messaging."
  value       = azurerm_servicebus_namespace.this.name
}

output "servicebus_connection_string" {
  description = "Connection string for the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "topic_name" {
  description = "Name of the Service Bus topic for cloud logging."
  value       = azurerm_servicebus_topic.cloud_log.name
}

output "topic_id" {
  description = "ID of the Service Bus topic."
  value       = azurerm_servicebus_topic.cloud_log.id
}

# Managed Identity outputs
output "managed_identity_id" {
  description = "ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.notification_identity.id
}

output "managed_identity_client_id" {
  description = "Client ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.notification_identity.client_id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the user-assigned managed identity."
  value       = azurerm_user_assigned_identity.notification_identity.principal_id
}

# Compatibility outputs for application configuration (matching AWS environment variable names)
output "notification_config" {
  description = "Configuration object containing all notification settings for application use."
  value = {
    # Azure-specific configuration
    azure_client_id                    = azuread_application.notification_app.client_id
    azure_client_secret               = azuread_application_password.notification_secret.value
    azure_tenant_id                   = data.azuread_client_config.current.tenant_id
    azure_communication_connection_string = azurerm_communication_service.this.primary_connection_string
    azure_servicebus_connection_string    = azurerm_servicebus_namespace.this.default_primary_connection_string
    azure_topic_name                  = azurerm_servicebus_topic.cloud_log.name
    azure_email_domain               = azurerm_email_communication_service_domain.this.name
    
    # AWS-compatible configuration (for application compatibility)
    aws_region                       = var.location
    aws_sns_access_key_id           = azuread_application.notification_app.client_id
    aws_sns_secret_access_key       = azuread_application_password.notification_secret.value
    aws_ses_access_key_id           = azuread_application.notification_app.client_id
    aws_ses_secret_access_key       = azuread_application_password.notification_secret.value
  }
  sensitive = true
}
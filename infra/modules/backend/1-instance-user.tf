# Azure Backend Instance Identity and Permissions - equivalent to AWS IAM role and policies
# Creates managed identity and role assignments for backend VM access to Azure resources

# User Assigned Managed Identity for the backend VM (equivalent to AWS IAM role)
resource "azurerm_user_assigned_identity" "this" {
  name                = "${var.instance_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Role assignment for Storage Account access (equivalent to AWS S3 bucket policy)
# Allows backend VM to access storage accounts for artifacts and frontend deployment
resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Role assignment for Storage Account Key access (for connection strings)
resource "azurerm_role_assignment" "storage_account_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Storage Account Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Role assignment for CDN management (equivalent to AWS CloudFront invalidation)
resource "azurerm_role_assignment" "cdn_profile_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "CDN Profile Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Role assignment for Communication Services access (for notifications)
resource "azurerm_role_assignment" "communication_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Role assignment for Service Bus access (for notifications)
resource "azurerm_role_assignment" "servicebus_data_sender" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Azure Service Bus Data Sender"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Role assignment for monitoring and logging (equivalent to AWS CloudWatch)
resource "azurerm_role_assignment" "monitoring_contributor" {
  scope                = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}

# Data source to get current Azure client configuration
data "azurerm_client_config" "current" {}
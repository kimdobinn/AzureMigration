# Frontend Outputs - equivalent to AWS S3 + CloudFront outputs
output "frontend_storage_account_name" {
  description = "Name of the storage account hosting the static website"
  value       = module.frontend.storage_account_name
}

output "frontend_website_urls" {
  description = "URLs for accessing the frontend website"
  value       = module.frontend.website_urls
}

output "frontend_cdn_endpoint" {
  description = "CDN endpoint hostname for the frontend"
  value       = module.frontend.cdn_endpoint_hostname
}

output "frontend_deployment_info" {
  description = "Information needed for CI/CD deployment to the frontend"
  value       = module.frontend.deployment_info
  sensitive   = true
}

# Backend Outputs - equivalent to AWS backend EC2 outputs
output "backend_vm_id" {
  description = "ID of the backend VM. Equivalent to AWS instance ID."
  value       = module.backend_vm.id
}

output "backend_vm_name" {
  description = "Name of the backend VM. Equivalent to AWS instance name."
  value       = module.backend_vm.name
}

output "backend_private_ip" {
  description = "Private IP address of the backend VM. Equivalent to AWS instance private IP."
  value       = module.backend_vm.private_ip_address
}

output "backend_api_endpoint" {
  description = "Backend API endpoint. Same as AWS."
  value       = module.backend_vm.backend_api_endpoint
}

output "backend_mq_endpoint" {
  description = "Backend MQ service endpoint. Same as AWS."
  value       = module.backend_vm.mqtt_service_endpoint
}

output "backend_stomp_endpoint" {
  description = "Backend STOMP service endpoint. Same as AWS."
  value       = module.backend_vm.stomp_service_endpoint
}

# Application Gateway Outputs - equivalent to AWS ALB outputs
output "application_gateway_id" {
  description = "ID of the Application Gateway. Equivalent to AWS ALB ID."
  value       = module.backend_lb.id
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway. Equivalent to AWS ALB DNS name."
  value       = module.backend_lb.public_ip_address
}

output "application_gateway_fqdn" {
  description = "FQDN of the Application Gateway. Equivalent to AWS ALB DNS name."
  value       = module.backend_lb.fqdn
}

output "application_gateway_endpoint" {
  description = "Main endpoint URL for the Application Gateway. Used by event-scheduler."
  value       = module.backend_lb.endpoint
}

# Event-Scheduler Outputs - equivalent to AWS event-scheduler outputs
output "event_scheduler_vm_id" {
  description = "ID of the event-scheduler VM"
  value       = module.event_scheduler_vm.id
}

output "event_scheduler_endpoint" {
  description = "Private IP endpoint of the event-scheduler VM"
  value       = module.event_scheduler_vm.endpoint
}

output "event_scheduler_connection_info" {
  description = "Connection information for backend services"
  value       = module.event_scheduler_vm.connection_info
}

# Database Outputs - equivalent to AWS RDS and DocumentDB outputs

# PostgreSQL Outputs - equivalent to AWS RDS Aurora outputs
output "postgresql_server_id" {
  description = "ID of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster ID."
  value       = module.postgresql.postgresql_server_id
}

output "postgresql_server_name" {
  description = "Name of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster identifier."
  value       = module.postgresql.postgresql_server_name
}

output "postgresql_server_fqdn" {
  description = "FQDN of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster endpoint."
  value       = module.postgresql.postgresql_server_fqdn
}

output "postgresql_database_name" {
  description = "Name of the PostgreSQL database."
  value       = module.postgresql.postgresql_database_name
}

# CosmosDB Outputs - equivalent to AWS DocumentDB outputs
output "cosmosdb_account_id" {
  description = "ID of the Cosmos DB account. Equivalent to AWS DocumentDB cluster ARN."
  value       = module.cosmosdb.cosmosdb_account_id
}

output "cosmosdb_account_name" {
  description = "Name of the Cosmos DB account. Equivalent to AWS DocumentDB cluster identifier."
  value       = module.cosmosdb.cosmosdb_account_name
}

output "cosmosdb_account_endpoint" {
  description = "Endpoint URL for the Cosmos DB account. Equivalent to AWS DocumentDB cluster endpoint."
  value       = module.cosmosdb.cosmosdb_account_endpoint
}

output "cosmosdb_database_name" {
  description = "Name of the MongoDB database within Cosmos DB."
  value       = module.cosmosdb.cosmosdb_database_name
}

# Network Outputs - equivalent to AWS VPC outputs
output "vnet_id" {
  description = "ID of the VNet. Equivalent to AWS VPC ID."
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the VNet."
  value       = module.vnet.vnet_name
}

output "vnet_address_space" {
  description = "Address space of the VNet. Equivalent to AWS VPC CIDR."
  value       = module.vnet.vnet_address_space
}

output "public_subnet_ids" {
  description = "IDs of the public subnets. Equivalent to AWS public subnet IDs."
  value       = module.vnet.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets. Equivalent to AWS private subnet IDs."
  value       = module.vnet.private_subnet_ids
}

output "nat_gateway_public_ip" {
  description = "Public IP address of the NAT Gateway. Equivalent to AWS NAT Gateway IP."
  value       = module.vnet.nat_public_ip
}
#Storage Account Outputs - equivalent to AWS S3 bucket outputs

# App Storage Account - equivalent to AWS app-bucket
output "app_storage_account_name" {
  description = "Name of the app storage account. Equivalent to AWS S3 app bucket name."
  value       = azurerm_storage_account.app_storage.name
}

output "app_storage_account_key" {
  description = "Primary access key for app storage account. Equivalent to AWS IAM user access key."
  value       = azurerm_storage_account.app_storage.primary_access_key
  sensitive   = true
}

output "app_storage_connection_string" {
  description = "Connection string for app storage account."
  value       = azurerm_storage_account.app_storage.primary_connection_string
  sensitive   = true
}

# Thumbnail Storage Account - equivalent to AWS thumbnail-bucket
output "thumbnail_storage_account_name" {
  description = "Name of the thumbnail storage account. Equivalent to AWS S3 thumbnail bucket name."
  value       = azurerm_storage_account.thumbnail_storage.name
}

output "thumbnail_storage_account_key" {
  description = "Primary access key for thumbnail storage account. Equivalent to AWS IAM user access key."
  value       = azurerm_storage_account.thumbnail_storage.primary_access_key
  sensitive   = true
}

output "thumbnail_storage_connection_string" {
  description = "Connection string for thumbnail storage account."
  value       = azurerm_storage_account.thumbnail_storage.primary_connection_string
  sensitive   = true
}

# Artifacts Storage Account - equivalent to AWS respiree-artifact-bucket
output "artifacts_storage_account_name" {
  description = "Name of the artifacts storage account. Equivalent to AWS S3 artifact bucket name."
  value       = azurerm_storage_account.artifacts_storage.name
}

output "artifacts_storage_account_key" {
  description = "Primary access key for artifacts storage account. Equivalent to AWS IAM user access key."
  value       = azurerm_storage_account.artifacts_storage.primary_access_key
  sensitive   = true
}

output "artifacts_storage_connection_string" {
  description = "Connection string for artifacts storage account."
  value       = azurerm_storage_account.artifacts_storage.primary_connection_string
  sensitive   = true
}
# Notification Outputs - equivalent to AWS SNS + SES outputs
output "notification_client_id" {
  description = "Client ID for notification service authentication. Equivalent to AWS access key ID."
  value       = module.notification.client_id
  sensitive   = false
}

output "notification_client_secret" {
  description = "Client secret for notification service authentication. Equivalent to AWS secret access key."
  value       = module.notification.client_secret
  sensitive   = true
}

output "notification_tenant_id" {
  description = "Azure AD tenant ID for notification service authentication."
  value       = module.notification.tenant_id
  sensitive   = false
}

output "notification_communication_service_name" {
  description = "Name of the Azure Communication Service for email delivery. Equivalent to AWS SES."
  value       = module.notification.communication_service_name
}

output "notification_servicebus_namespace" {
  description = "Name of the Service Bus namespace for topic messaging. Equivalent to AWS SNS."
  value       = module.notification.servicebus_namespace_name
}

output "notification_topic_name" {
  description = "Name of the Service Bus topic for cloud logging. Equivalent to AWS SNS topic."
  value       = module.notification.topic_name
}

output "notification_config" {
  description = "Complete notification configuration for application use. Contains both Azure and AWS-compatible settings."
  value       = module.notification.notification_config
  sensitive   = true
}

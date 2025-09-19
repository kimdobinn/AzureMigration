#Environment
variable "location" {
  description = "Code for target Azure location for deployment e.g. ap-southeast-2."
  type        = string
}

# resource_group_name is now dynamically generated in locals as rg-{location_code}-{environment}

variable "location_code" {
  description = "Location code used for naming resources e.g. sgp (Singapore), aus (Australia), usa (United States)."
  type        = string
}

variable "environment" {
  description = "System environment type e.g. dev, stg, prd."
  type        = string
}

#Network
variable "vnet_address_space" {
  description = "Address space for the virtual network in CIDR notation."
  type        = list(string)
}

variable "web_address_space_1" {
  description = "1st address space for Web layer."
  type        = string
}

variable "web_address_space_2" {
  description = "2nd address space for Web layer to support Application Load Balancer's availability."
  type        = string
}

variable "app_address_space" {
  description = "Address space for Application layer."
  type        = string  
}

variable "db_address_space_1" {
  description = "1st address space for Database layer."
  type        = string
}

variable "db_address_space_2" {
  description = "2nd address space for Database layer to support high availability."
  type        = string
}

#Database
variable "postgresql_version" {
  description = "Version of PostgreSQL to use for the Flexible Server."
  type        = string
  default     = "15"
}
variable "postgresql_flexible_server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  type        = string
}
variable "postgresql_flexible_server_sku_name" {
  description = "SKU name for the PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "postgresql_flexible_server_storage_mb" {
  description = "Storage size in MB for the PostgreSQL Flexible Server."
  type        = number
  default     = 32768
}
variable "postgresql_flexible_server_tags" {
  description = "Tags to apply to the PostgreSQL Flexible Server."
  type        = map(string)
  default     = {
    environment = "development"
    team        = "database"
  }
}
# postgresql_flexible_server_resource_group_name is now dynamically managed
variable "postgresql_flexible_server_location" {
  description = "Azure region where the PostgreSQL Flexible Server will be deployed."
  type        = string
}
variable "postgresql_flexible_server_admin_username" {
  description = "Administrator username for the PostgreSQL Flexible Server."
  type        = string
  default     = "psqladmin"
}
variable "postgresql_flexible_server_admin_password" {
  description = "Administrator password for the PostgreSQL Flexible Server."
  type        = string
  sensitive   = true
}


# COSMOS DB 
variable "cosmosdb_mongo_throughput" {
  description = "Request Units per second for Cosmos DB MongoDB database. Equivalent to AWS DocumentDB instance sizing."
  type        = number
  default     = 400  # 400 RU/s is roughly equivalent to AWS DocumentDB db.t3.small for development
}

variable "cosmosdb_backup_retention_hours" {
  description = "Backup retention period in hours for Cosmos DB. Equivalent to AWS DocumentDB backup retention."
  type        = number
  default     = 168  # 7 days (168 hours) - matches typical AWS DocumentDB backup retention
}

variable "cosmosdb_enable_multi_region" {
  description = "Enable multi-region deployment for Cosmos DB. Set to true for production HA beyond AWS DocumentDB capabilities."
  type        = bool
  default     = false  # Keep false to match single-region AWS DocumentDB setup
}

variable "cosmosdb_secondary_region" {
  description = "Secondary region for Cosmos DB multi-region deployment. Only used if cosmosdb_enable_multi_region is true."
  type        = string
  default     = "australiasoutheast"  # Closest region to australiaeast for DR
}
# Service Bus (Message Queue) Configuration - equivalent to AWS MQ
variable "servicebus_sku" {
  description = "Service Bus SKU. Standard for dev/test, Premium for production. Equivalent to AWS MQ instance_type."
  type        = string
  default     = "Standard"
}

variable "servicebus_capacity" {
  description = "Service Bus capacity (only for Premium SKU). Equivalent to AWS MQ instance scaling."
  type        = number
  default     = 1
}

variable "servicebus_publicly_accessible" {
  description = "Whether the Service Bus is publicly accessible. Equivalent to AWS MQ publicly_accessible."
  type        = bool
  default     = true
}

# Note: Zone redundancy is automatically available for Premium SKU Service Bus

# Note: Partitioning in Azure Service Bus is handled automatically

variable "servicebus_max_topic_size_mb" {
  description = "Maximum size of the topic in MB. Equivalent to AWS MQ storage limits."
  type        = number
  default     = 1024
}

variable "servicebus_max_queue_size_mb" {
  description = "Maximum size of the queue in MB. Equivalent to AWS MQ storage limits."
  type        = number
  default     = 1024
}

variable "servicebus_default_message_ttl" {
  description = "Default message time-to-live. Equivalent to AWS MQ message expiration."
  type        = string
  default     = "P14D"  # 14 days
}

variable "servicebus_max_delivery_count" {
  description = "Maximum delivery attempts before dead letter queue. Equivalent to AWS MQ redelivery policy."
  type        = number
  default     = 10
}

variable "servicebus_create_private_endpoint" {
  description = "Create private endpoint for VNet integration. Equivalent to AWS MQ VPC placement."
  type        = bool
  default     = false
}

# Message Queue Topic and Queue Names (same as AWS MQ)
variable "mq_gw_report_topic_name" {
  description = "Name of topic for gateway reports. Same as AWS MQ topic name."
  type        = string
  default     = "gateway.reports"
}

variable "mq_gw_report_queue_name" {
  description = "Name of queue for gateway reports. Same as AWS MQ queue name."
  type        = string
  default     = "gateway.reports.queue"
}

# Frontend (Static Website) Configuration - equivalent to AWS S3 + CloudFront
variable "frontend_replication_type" {
  description = "Storage replication type. LRS for dev, GRS for prod. Equivalent to AWS S3 replication."
  type        = string
  default     = "LRS"
}

variable "frontend_public_network_access" {
  description = "Enable public network access to storage. Equivalent to AWS S3 public access settings."
  type        = bool
  default     = true
}

variable "frontend_allow_public_access" {
  description = "Allow public access to blobs. Equivalent to AWS S3 public read access."
  type        = bool
  default     = true
}

variable "frontend_enable_versioning" {
  description = "Enable blob versioning. Equivalent to AWS S3 versioning."
  type        = bool
  default     = true
}

variable "frontend_index_document" {
  description = "Index document for static website. Equivalent to AWS CloudFront default_root_object."
  type        = string
  default     = "index.html"
}

variable "frontend_error_404_document" {
  description = "404 error document. Equivalent to AWS CloudFront custom error pages."
  type        = string
  default     = "404.html"
}

variable "frontend_allowed_origins" {
  description = "CORS allowed origins. Equivalent to AWS S3 CORS configuration."
  type        = list(string)
  default     = ["*"]
}

variable "frontend_cdn_sku" {
  description = "Azure CDN SKU. Equivalent to AWS CloudFront price class."
  type        = string
  default     = "Standard_Microsoft"
}

variable "frontend_cache_duration" {
  description = "Cache duration. Equivalent to AWS CloudFront TTL settings."
  type        = string
  default     = "1.00:00:00"
}

variable "frontend_custom_domain_name" {
  description = "Custom domain name. Equivalent to AWS CloudFront aliases."
  type        = string
  default     = null
}

variable "frontend_enable_https" {
  description = "Enable HTTPS for custom domain. Equivalent to AWS CloudFront SSL."
  type        = bool
  default     = true
}

variable "frontend_minimum_tls_version" {
  description = "Minimum TLS version. Equivalent to AWS CloudFront minimum_protocol_version."
  type        = string
  default     = "TLS12"
}

variable "frontend_geo_restrictions" {
  description = "Country codes for geo-filtering. Equivalent to AWS CloudFront geo restrictions."
  type        = list(string)
  default     = []
}

variable "frontend_geo_restriction_action" {
  description = "Geo-filtering action: Allow or Block. Equivalent to AWS CloudFront restriction type."
  type        = string
  default     = "Allow"
}

variable "frontend_enable_network_rules" {
  description = "Enable network access rules. Equivalent to AWS S3 bucket policy restrictions."
  type        = bool
  default     = false
}

variable "frontend_default_network_action" {
  description = "Default network access action. Equivalent to AWS S3 bucket policy default action."
  type        = string
  default     = "Allow"
}

variable "frontend_allowed_ip_ranges" {
  description = "Allowed IP ranges. Equivalent to AWS S3 bucket policy IP restrictions."
  type        = list(string)
  default     = []
}

variable "frontend_allowed_subnet_ids" {
  description = "Allowed subnet IDs. Equivalent to AWS S3 VPC endpoint access."
  type        = list(string)
  default     = []
}# Event Scheduler Configuration - equivalent to AWS event-scheduler
variable "event_scheduler_port" {
  description = "Application port number for event scheduler. Same as AWS."
  type        = number
  default     = 8081
}

variable "event_scheduler_vm_size" {
  description = "Azure VM size for event-scheduler. Equivalent to AWS instance_type."
  type        = string
  default     = "Standard_B1s"  # Equivalent to AWS t2.micro
}

variable "event_scheduler_os_disk_type" {
  description = "OS disk storage type for event-scheduler VM. Equivalent to AWS EBS volume type."
  type        = string
  default     = "Premium_LRS"
}

variable "event_scheduler_os_disk_size" {
  description = "OS disk size in GB for event-scheduler VM. Equivalent to AWS EBS volume size."
  type        = number
  default     = 30
}

variable "ssh_public_key" {
  description = "SSH public key for VM access. Equivalent to AWS authorization_key."
  type        = string
}

# Secret/Sensitive Variables - equivalent to AWS Secrets Manager
variable "cosmosdb_master_user_username" {
  description = "Master username for Cosmos DB. Equivalent to AWS DocumentDB master username."
  type        = string
  default     = "cosmosadmin"
}

variable "cosmosdb_master_user_password" {
  description = "Master password for Cosmos DB. Equivalent to AWS DocumentDB master password."
  type        = string
  sensitive   = true
}

variable "inter_server_auth_key" {
  description = "API key used by event-scheduler and backend-api to communicate. Same as AWS."
  type        = string
  sensitive   = true
}

# Storage Account for Artifacts - equivalent to AWS S3 artifact bucket
variable "artifacts_storage_account_name" {
  description = "Name of storage account containing application artifacts. Equivalent to AWS S3 artifact bucket."
  type        = string
  default     = "audevartifacts"  # Will be created separately
}

variable "artifacts_storage_account_key" {
  description = "Access key for artifacts storage account. Equivalent to AWS S3 access credentials."
  type        = string
  sensitive   = true
  default     = "placeholder-key"  # Replace with actual key after creating storage account
}
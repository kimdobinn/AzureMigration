# Environment for infrastructure
variable "location" {
  description = "Code for target Azure location for deployment e.g. australiaeast."
  type        = string
}

variable "location_code" {
  description = "Location code used for naming resources e.g. au (Australia), sgp (Singapore), usa (United States)."
  type        = string
}

variable "environment" {
  description = "System environment type e.g. dev, stg, prd."
  type        = string
}

# Networking
variable "vnet_address_space" {
  description = "Address space for the virtual network in CIDR notation. Equivalent to AWS VPC CIDR block."
  type        = list(string)
}

variable "web_address_space_1" {
  description = "1st address space for Web layer. This is public facing. Must be within the VNet address space."
  type        = string
}

variable "web_address_space_2" {
  description = "2nd address space for Web layer to support Application Gateway's availability. This is public facing. Must be within the VNet address space."
  type        = string
}

variable "app_address_space" {
  description = "Address space for Application layer. Must be within the VNet address space."
  type        = string
}

variable "db_address_space_1" {
  description = "1st address space for Database layer. Must be within the VNet address space."
  type        = string
}

variable "db_address_space_2" {
  description = "2nd address space for Database layer to support high availability. Must be within the VNet address space."
  type        = string
}

# PostgreSQL Flexible Server (equivalent to AWS RDS)
variable "postgresql_flexible_server_admin_password" {
  description = "Administrator password for the PostgreSQL Flexible Server. Equivalent to AWS RDS master password."
  type        = string
  sensitive   = true
}

variable "postgresql_flexible_server_admin_username" {
  description = "Administrator username for the PostgreSQL Flexible Server. Equivalent to AWS RDS master username."
  type        = string
}

variable "postgresql_flexible_server_location" {
  description = "Azure region for PostgreSQL Flexible Server deployment."
  type        = string
}

variable "postgresql_flexible_server_name" {
  description = "Name of the PostgreSQL Flexible Server."
  type        = string
}

variable "postgresql_flexible_server_sku_name" {
  description = "SKU name for PostgreSQL Flexible Server. Equivalent to AWS RDS instance class."
  type        = string
}

variable "postgresql_flexible_server_storage_mb" {
  description = "Storage size in MB for PostgreSQL Flexible Server."
  type        = number
}

variable "postgresql_version" {
  description = "PostgreSQL version."
  type        = number
}

# CosmosDB (equivalent to AWS DocumentDB)
variable "cosmosdb_mongo_throughput" {
  description = "Throughput configuration for CosmosDB MongoDB API. Equivalent to AWS DocumentDB instance sizing."
  type        = number
}

variable "cosmosdb_backup_retention_hours" {
  description = "Backup retention period in hours for CosmosDB."
  type        = number
}

variable "cosmosdb_enable_multi_region" {
  description = "Enable multi-region replication for CosmosDB."
  type        = bool
  default     = false
}

variable "cosmosdb_secondary_region" {
  description = "Secondary region for CosmosDB multi-region setup."
  type        = string
  default     = null
}

# Message Queue (ActiveMQ - same as AWS)
variable "mq_stomp_port" {
  description = "ActiveMQ STOMP port for real-time communication. Same as AWS."
  type        = number
  default     = 61613
}

variable "mq_gw_report_topic_name" {
  description = "The topic which Respiree gateways will send their report to. Same as AWS."
  type        = string
}

variable "mq_gw_report_queue_name" {
  description = "The queue which ActiveMQ will pipe the Respiree gateway report messages to. Same as AWS."
  type        = string
}

# Notification (equivalent to AWS SNS + SES)
variable "notification_subscription_email_addresses" {
  description = "List of email addresses that will receive notifications from the cloud logging system. Equivalent to AWS SNS email subscriptions."
  type        = list(string)
  default     = []
}

variable "notification_servicebus_sku" {
  description = "SKU for the Service Bus namespace. Standard tier supports topics and subscriptions (equivalent to AWS SNS)."
  type        = string
  default     = "Standard"
}

variable "notification_topic_max_size_mb" {
  description = "Maximum size of the Service Bus topic in megabytes."
  type        = number
  default     = 1024
}

variable "notification_message_ttl_days" {
  description = "Default message time-to-live in days for notification messages."
  type        = number
  default     = 14
}

variable "notification_enable_duplicate_detection" {
  description = "Enable duplicate detection for the Service Bus topic to prevent duplicate notifications."
  type        = bool
  default     = true
}

variable "notification_duplicate_detection_window_minutes" {
  description = "Duplicate detection history time window in minutes."
  type        = number
  default     = 10
}

# Backend API (same as AWS)
variable "backend_env_flag" {
  description = "Environment flags for the backend-api's env variable. Values include 'development','staging' and 'production'. Same as AWS."
  type        = string
}

variable "backend_proxy_port" {
  description = "Application port number masking main backend API's actual port. Same as AWS."
  type        = number
}

variable "backend_port" {
  description = "Application port number for main backend API. Same as AWS."
  type        = number
}

variable "backend_notification_sender" {
  description = "Default notification sender ID. Equivalent to AWS SNS sender."
  type        = string
}

variable "backend_notification_email_sender" {
  description = "Default Email sender. Equivalent to AWS SES sender."
  type        = string
}

# Event Scheduler (same as AWS)
variable "event_scheduler_port" {
  description = "Application port number for event scheduler. Same as AWS."
  type        = number
}

# Data Processing (same as AWS)
variable "data_processing_endpoint" {
  description = "Application endpoint for data processing backend API. Same as AWS."
  type        = string
}

variable "data_processing_port" {
  description = "Application port number for data processing backend API. Same as AWS."
  type        = number
}

# MQ Services (MQTT / STOMP) - same as AWS
variable "mqtt_service_is_prod" {
  description = "Boolean flag to configure MQTT as production. Same as AWS."
  type        = number
}

variable "mq_service_port" {
  description = "Application port number for MQTT service. Not to be confused with the port number of the ActiveMQ MQTT port. Same as AWS."
  type        = number
}

variable "stomp_service_port" {
  description = "Application port number for STOMP service. Not to be confused with the port number of the ActiveMQ STOMP port. Same as AWS."
  type        = number
}

variable "stomp_service_gateway_ping_endpoint" {
  description = "Endpoint for STOMP service to send Respiree gateway ping messages to. Same as AWS."
  type        = string
}

# Firebase (same as AWS)
variable "firebase_project_id" {
  description = "ID of the Firebase project. Stored in the database for frontend dashboard to use. Same as AWS."
  type        = string
}

variable "firebase_storage_bucket" {
  description = "Storage bucket ID of the Firebase project. Stored in the database for frontend dashboard to use. Same as AWS."
  type        = string
}

variable "firebase_message_sender_id" {
  description = "The Firebase Cloud Messaging sender ID stored in the database for frontend dashboard to use. Same as AWS."
  type        = string
}

variable "firebase_auth_domain" {
  description = "The authentication domain which users are directed to for Firebase Auth Domain authentication. Stored in the database for frontend dashboard to use. Same as AWS."
  type        = string
}

variable "firebase_app_id" {
  description = "ID of Firebase application. Stored in the database for frontend dashboard to use. Same as AWS."
  type        = string
}

variable "firebase_app_measurement_id" {
  description = "ID of Firebase App Measurement. Stored in the database for frontend dashboard to use. Same as AWS."
  type        = string
}

# Mobile App Versions (same as AWS)
variable "mobile_app_aus_ios_version" {
  description = "Australia iOS mobile app version. Stored in database. Same as AWS."
  type        = string
}

variable "mobile_app_sgp_ios_version" {
  description = "Singapore iOS mobile app version. Stored in database. Same as AWS."
  type        = string
}

variable "mobile_app_usa_ios_version" {
  description = "USA iOS mobile app version. Stored in database. Same as AWS."
  type        = string
}

variable "mobile_app_aus_android_version" {
  description = "Australia Android mobile app version. Stored in database. Same as AWS."
  type        = string
}

variable "mobile_app_sgp_android_version" {
  description = "Singapore Android mobile app version. Stored in database. Same as AWS."
  type        = string
}

variable "mobile_app_usa_android_version" {
  description = "USA Android mobile app version. Stored in database. Same as AWS."
  type        = string
}

# SSH Configuration (equivalent to AWS authorization_key)
variable "ssh_public_key" {
  description = "An SSH authorization key is a cryptographic key used to authenticate a user or device. Equivalent to AWS authorization_key."
  type        = string
}

# Additional variables needed by the configuration files

# Backend VM Configuration
variable "backend_instance_type" {
  description = "Azure VM size for backend instance. Equivalent to AWS instance type."
  type        = string
  default     = "Standard_B2s"
}

variable "backend_os_disk_type" {
  description = "Backend VM OS disk type."
  type        = string
  default     = "Premium_LRS"
}

variable "backend_os_disk_size" {
  description = "Backend VM OS disk size in GB."
  type        = number
  default     = 30
}



# Message Queue Configuration
variable "mq_username" {
  description = "ActiveMQ username. Same as AWS."
  type        = string
  default     = "admin"
}

variable "mq_password" {
  description = "ActiveMQ password. Same as AWS."
  type        = string
  default     = "admin123"
}

variable "mq_port" {
  description = "ActiveMQ port for backend communication. Same as AWS."
  type        = number
  default     = 61616
}

# Application Gateway Configuration
variable "backend_lb_sku_name" {
  description = "Application Gateway SKU name."
  type        = string
  default     = "Standard_v2"
}

variable "backend_lb_sku_tier" {
  description = "Application Gateway SKU tier."
  type        = string
  default     = "Standard_v2"
}

variable "backend_lb_capacity" {
  description = "Application Gateway capacity."
  type        = number
  default     = 2
}

variable "backend_ssl_certificate_id" {
  description = "SSL certificate ID for Application Gateway."
  type        = string
  default     = null
}

# Service API Keys (with defaults for development)
variable "mq_service_api_key" {
  description = "MQ service API key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "stomp_service_gateway_ping_api_key" {
  description = "STOMP service gateway ping API key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "data_processing_api_key" {
  description = "Data processing service API key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

# Backend API Keys
variable "backend_jwt_secret" {
  description = "JWT secret for backend authentication. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "backend_jwt_refresh_secret" {
  description = "JWT refresh secret for backend authentication. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "backend_service_api_key" {
  description = "Backend service API key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "backend_firebase_account_key" {
  description = "Firebase account key for backend. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "backend_super_admin" {
  description = "Backend super admin user. Same as AWS."
  type        = string
  default     = "respiree_admin"
}

# Third-party Integration Keys
variable "agora_app_id" {
  description = "Agora application ID. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "agora_app_cert" {
  description = "Agora application certificate. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "connecty_cube_app_id" {
  description = "ConnectyCube application ID. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "connecty_cube_auth_key" {
  description = "ConnectyCube authorization key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "connecty_cube_auth_secret" {
  description = "ConnectyCube authorization secret. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

# Firebase API Key
variable "firebase_api_key" {
  description = "Firebase API key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

# Security Keys
variable "dialog_env_key" {
  description = "Dialog environment key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

variable "inter_server_auth_key" {
  description = "Inter-server authentication key. Same as AWS."
  type        = string
  default     = "change-me-in-production"
}

# Frontend Configuration
variable "frontend_local_storage_token" {
  description = "Frontend local storage token. Same as AWS."
  type        = string
  default     = "respiree-token"
}

# Frontend Storage Configuration (equivalent to AWS S3 config)
variable "frontend_storage_config" {
  description = "Configuration for frontend's Storage Account. Equivalent to AWS S3 config."
  type = object({
    replication_type              = string
    public_network_access_enabled = bool
    allow_public_access           = bool
    enable_versioning             = bool
    index_document                = string
    error_404_document            = string
    allowed_origins               = list(string)
    enable_network_rules          = bool
    default_network_action        = string
    allowed_ip_ranges             = list(string)
    allowed_subnet_ids            = list(string)
  })
  default = {
    replication_type              = "LRS"
    public_network_access_enabled = true
    allow_public_access           = true
    enable_versioning             = false
    index_document                = "index.html"
    error_404_document            = "404.html"
    allowed_origins               = ["*"]
    enable_network_rules          = false
    default_network_action        = "Allow"
    allowed_ip_ranges             = []
    allowed_subnet_ids            = []
  }
}

# Frontend CDN Configuration (equivalent to AWS CloudFront config)
variable "frontend_cdn_config" {
  description = "Configuration for frontend's CDN. Equivalent to AWS CloudFront config."
  type = object({
    sku                    = string
    cache_duration         = number
    custom_domain_name     = string
    enable_https           = bool
    minimum_tls_version    = string
    geo_restrictions       = list(string)
    geo_restriction_action = string
  })
  default = {
    sku                    = "Standard_Microsoft"
    cache_duration         = 3600
    custom_domain_name     = null
    enable_https           = true
    minimum_tls_version    = "TLS12"
    geo_restrictions       = []
    geo_restriction_action = "Allow"
  }
}

# Event Scheduler Configuration
variable "event_scheduler_vm_size" {
  description = "Azure VM size for event scheduler instance."
  type        = string
  default     = "Standard_B1s"
}

variable "event_scheduler_os_disk_type" {
  description = "Event scheduler VM OS disk type."
  type        = string
  default     = "Premium_LRS"
}

variable "event_scheduler_os_disk_size" {
  description = "Event scheduler VM OS disk size in GB."
  type        = number
  default     = 30
}

# CosmosDB User Configuration
variable "cosmosdb_master_user_username" {
  description = "Master username for Cosmos DB. Equivalent to AWS DocumentDB master username."
  type        = string
  default     = "cosmosadmin"
}

variable "cosmosdb_master_user_password" {
  description = "Master password for Cosmos DB. Equivalent to AWS DocumentDB master password."
  type        = string
  default     = "change-me-in-production"
}

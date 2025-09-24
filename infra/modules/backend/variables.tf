# Azure Backend Module Variables - equivalent to AWS backend variables
# Maintains compatibility with AWS structure while adapting to Azure resources

# Instance Configuration (Azure VM equivalent to AWS EC2)
variable "instance_type" {
  description = "Azure VM size e.g. Standard_B2s. Equivalent to AWS instance type."
  type        = string
}

variable "instance_name" {
  description = "Name of VM resource. Same as AWS."
  type        = string
}

variable "location" {
  description = "Azure region for VM deployment. Equivalent to AWS region."
  type        = string
}

variable "resource_group_name" {
  description = "Azure resource group name. Equivalent to AWS VPC context."
  type        = string
}

variable "artifact_folder" {
  description = "Azure Storage container path of artifacts. Equivalent to AWS S3 path."
  type        = string
}

variable "authorization_key" {
  description = "VM SSH authorization key for default user ubuntu. Equivalent to AWS ec2-user key."
  type        = string
}

variable "storage_account_name" {
  description = "Azure Storage Account name for artifacts. Equivalent to AWS S3 bucket."
  type        = string
}

variable "storage_account_key" {
  description = "Azure Storage Account access key. Equivalent to AWS S3 access credentials."
  type        = string
}

# Network Configuration (Azure VNet equivalent to AWS VPC)
variable "subnet_id" {
  description = "ID of the subnet which the VM will be created in. Same as AWS."
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the VM. Equivalent to AWS security group rules."
  type        = list(string)
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for VM access. Same as AWS."
  type        = string
}

# Storage Configuration (Azure Managed Disk equivalent to AWS EBS)
variable "root_block_device" {
  description = "Object containing settings for VM's OS disk. Equivalent to AWS root block device."
  type = object({
    caching     = optional(string, "ReadWrite")
    volume_type = optional(string, "Premium_LRS")
    volume_size = optional(number, 30)
  })
  default = {}
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the VM resources. Same as AWS."
  type        = map(string)
  default     = {}
}

# Configuration
variable "user_data" {
  description = "Additional scripts that will be executed on top of the default configuration. Same as AWS."
  type        = string
  default     = ""
}

# Database Configuration (Azure PostgreSQL equivalent to AWS RDS)
variable "rds_db" {
  description = "Object containing information on the provisioned PostgreSQL database. Equivalent to AWS RDS."
  type = object({
    username = string
    password = string
    name     = string
    host     = string
    port     = string
  })
}

# Message Queue Configuration (ActiveMQ on VM, same as AWS)
variable "mq" {
  description = "Object containing information for ActiveMQ configuration. Same as AWS."
  type = object({
    ssl_used             = number
    username             = string
    password             = string
    endpoint             = string
    port                 = number
    stomp_port           = number
    gw_report_topic_name = string
    gw_report_queue_name = string
  })
}

# Frontend Configuration (Azure Storage + CDN equivalent to AWS S3 + CloudFront)
variable "frontend_dashboard" {
  description = "Object containing information for the frontend dashboard. Equivalent to AWS S3 + CloudFront."
  type = object({
    app_bucket_name     = string
    thumbnail_bucket_name = string
    endpoint            = string
    local_storage_token = string
  })
}

# Backend API Configuration
variable "backend_api" {
  description = "Object containing information for backend-api service. Same structure as AWS."
  type = object({
    endpoint                  = string
    proxy_port                = number
    port                      = number
    env_flag                  = string
    jwt_secret                = string
    jwt_refresh_secret        = string
    service_api_key           = string
    notification_sender       = string
    notification_email_sender = string
    super_admin               = string
    firebase_account_key      = string
  })
}

# Event Scheduler Configuration
variable "event_scheduler" {
  description = "Object containing information for event-scheduler service. Same as AWS."
  type = object({
    host = string
    port = number
  })
}

# Data Processing Configuration
variable "data_processing" {
  description = "Object containing information for data processing service. Same as AWS."
  type = object({
    endpoint = string
    port     = number
    api_key  = string
  })
}

# MQTT Service Configuration
variable "mqtt_service" {
  description = "Object containing information for mqtt-service. Same as AWS."
  type = object({
    is_prod = number
    host    = string
    port    = number
  })
}

# STOMP Service Configuration
variable "stomp_service" {
  description = "Object containing information for stomp-service. Same as AWS."
  type = object({
    host                  = string
    port                  = number
    gateway_ping_endpoint = string
    gateway_ping_source   = string
    gateway_ping_api_key  = string
  })
}

# MQ Service API Key
variable "mq_service_api_key" {
  description = "API key used by backend-api, mqtt-service and stomp-service to communicate. Same as AWS."
  type        = string
}

# Third-party Integrations (same as AWS)
variable "agora" {
  description = "Object containing information for Agora. Same as AWS."
  type = object({
    app_id   = string,
    app_cert = string
  })
}

variable "connecty_cube" {
  description = "Object containing information for ConnectyCube. Same as AWS."
  type = object({
    app_id      = string,
    auth_key    = string,
    auth_secret = string
  })
}

variable "inter_server_auth_key" {
  description = "API key used by backend-api and event-scheduler to communicate. Same as AWS."
  type        = string
}

variable "firebase" {
  description = "Object containing information for Firebase. Same as AWS."
  type = object({
    project_id         = string
    app_id             = string
    storage_bucket     = string
    app_measurement_id = string
    api_key            = string
    message_sender_id  = string
    auth_domain        = string
  })
}

variable "mobile_app_versions" {
  description = "Object containing all the mobile app versions. Same as AWS."
  type = object({
    aus_ios     = string
    sgp_ios     = string
    usa_ios     = string
    aus_android = string
    sgp_android = string
    usa_android = string
  })
}

variable "dialog_env_key" {
  description = "Dialog environment key. Same as AWS."
  type        = string
}

# Notification Configuration (Azure Communication Services + Service Bus equivalent to AWS SNS + SES)
variable "notification_config" {
  description = "Notification service configuration containing Azure Communication Services and Service Bus settings. Equivalent to AWS SNS + SES configuration."
  type = object({
    # Azure-specific configuration
    azure_client_id                       = string
    azure_client_secret                   = string
    azure_tenant_id                       = string
    azure_communication_connection_string = string
    azure_servicebus_connection_string    = string
    azure_topic_name                      = string
    azure_email_domain                    = string
    
    # AWS-compatible configuration (for application compatibility)
    aws_region                = string
    aws_sns_access_key_id     = string
    aws_sns_secret_access_key = string
    aws_ses_access_key_id     = string
    aws_ses_secret_access_key = string
  })
  sensitive = true
}
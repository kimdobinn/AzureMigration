# Basic Configuration
variable "namespace_name" {
  description = "Name of the Service Bus namespace. Equivalent to AWS MQ broker name."
  type        = string
}

variable "location" {
  description = "Azure region for the Service Bus namespace. Equivalent to AWS region."
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name. No AWS equivalent - Azure-specific requirement."
  type        = string
}

# Service Bus Configuration (equivalent to AWS MQ broker settings)
variable "sku" {
  description = "Service Bus SKU. Basic/Standard/Premium. Equivalent to AWS MQ instance_type (mq.t2.micro = Basic, mq.t3.small = Standard, mq.m5.large+ = Premium)."
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "capacity" {
  description = "Service Bus capacity (only for Premium SKU). Equivalent to AWS MQ instance scaling."
  type        = number
  default     = 1
  
  validation {
    condition     = var.capacity >= 1 && var.capacity <= 16
    error_message = "Capacity must be between 1 and 16."
  }
}

variable "publicly_accessible" {
  description = "Whether the Service Bus is publicly accessible. Equivalent to AWS MQ publicly_accessible."
  type        = bool
  default     = true
}

# Note: Zone redundancy is automatically available for Premium SKU Service Bus
# in supported Azure regions. No explicit configuration needed.

# Topic and Queue Configuration (equivalent to AWS MQ destinations)
variable "gw_report_topic_name" {
  description = "Name of the Service Bus topic for gateway reports. Equivalent to AWS MQ topic."
  type        = string
}

variable "gw_report_queue_name" {
  description = "Name of the Service Bus queue for gateway reports. Equivalent to AWS MQ queue."
  type        = string
}

# Note: Partitioning in Azure Service Bus is handled automatically by the service
# No explicit configuration is needed

variable "max_topic_size_mb" {
  description = "Maximum size of the topic in MB. Equivalent to AWS MQ storage limits."
  type        = number
  default     = 1024
}

variable "max_queue_size_mb" {
  description = "Maximum size of the queue in MB. Equivalent to AWS MQ storage limits."
  type        = number
  default     = 1024
}

variable "default_message_ttl" {
  description = "Default message time-to-live in ISO 8601 format. Equivalent to AWS MQ message expiration."
  type        = string
  default     = "P14D"  # 14 days
}

variable "max_delivery_count" {
  description = "Maximum delivery attempts before moving to dead letter queue. Equivalent to AWS MQ redelivery policy."
  type        = number
  default     = 10
}

# Network Configuration (equivalent to AWS MQ VPC settings)
variable "create_private_endpoint" {
  description = "Create private endpoint and NSG for VNet integration. Equivalent to AWS MQ VPC placement."
  type        = bool
  default     = false
}

variable "app_subnet_cidr" {
  description = "CIDR block of the app subnet for security rules. Equivalent to AWS MQ security group source."
  type        = string
  default     = "10.0.0.0/8"
}

# Tags
variable "tags" {
  description = "Tags to apply to Service Bus resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}
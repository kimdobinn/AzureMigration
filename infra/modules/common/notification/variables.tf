# Azure Notification Module Variables - equivalent to AWS SNS + SES variables

variable "location" {
  description = "The Azure region used for creating notification resources. Equivalent to AWS region."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where notification resources will be created."
  type        = string
}

variable "resource_name_prefix" {
  description = "A text prefix using standard dashed case to name notification resources."
  type        = string
}

variable "topic_name" {
  description = "Name of Service Bus topic to be created. Used for distributing messages to subscribers. Equivalent to AWS SNS topic name."
  type        = string
}

variable "subscription_email_addresses" {
  description = "A list of email addresses that will receive notifications. Note: Azure Communication Services requires domain verification for production use."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to assign to the notification resources."
  type        = map(string)
  default     = {}
}

# Optional variables for advanced configuration

variable "servicebus_sku" {
  description = "The SKU of the Service Bus namespace. Standard supports topics and subscriptions."
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.servicebus_sku)
    error_message = "Service Bus SKU must be Basic, Standard, or Premium."
  }
}

variable "topic_max_size_mb" {
  description = "Maximum size of the Service Bus topic in megabytes."
  type        = number
  default     = 1024
}

variable "message_ttl_days" {
  description = "Default message time-to-live in days."
  type        = number
  default     = 14
}

variable "enable_duplicate_detection" {
  description = "Enable duplicate detection for the Service Bus topic."
  type        = bool
  default     = true
}

variable "duplicate_detection_window_minutes" {
  description = "Duplicate detection history time window in minutes."
  type        = number
  default     = 10
}
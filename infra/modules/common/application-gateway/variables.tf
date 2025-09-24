# Azure Application Gateway Module Variables - equivalent to AWS ALB variables

# Basic Configuration
variable "name" {
  description = "Name of the Application Gateway. Equivalent to AWS ALB name."
  type        = string
}

variable "location" {
  description = "Azure region to deploy the Application Gateway. Equivalent to AWS region."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group. No AWS equivalent."
  type        = string
}

# Network Configuration
variable "subnet_id" {
  description = "Subnet ID for the Application Gateway. Equivalent to AWS ALB subnets."
  type        = string
}

variable "backend_vm_network_interface_ids" {
  description = "List of backend VM network interface IDs. Equivalent to AWS Target Group instances."
  type        = list(string)
  default     = []
}

# Application Gateway Configuration
variable "sku_name" {
  description = "SKU name for Application Gateway. Equivalent to AWS ALB type."
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier for Application Gateway. Equivalent to AWS ALB type."
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Capacity (instance count) for Application Gateway. Equivalent to AWS ALB capacity."
  type        = number
  default     = 2
}

# Backend Configuration
variable "backend_port" {
  description = "Port that backend VMs listen on. Equivalent to AWS Target Group port."
  type        = number
  default     = 8080
}

variable "health_check_path" {
  description = "Health check path for backend VMs. Equivalent to AWS Target Group health check."
  type        = string
  default     = "/api"
}

# SSL Configuration
variable "ssl_certificate_id" {
  description = "Key Vault secret ID for SSL certificate. Equivalent to AWS ACM certificate ARN."
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to Application Gateway resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}
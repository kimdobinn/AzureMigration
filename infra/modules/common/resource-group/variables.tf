variable "resource_group_name" {
  description = "Name of the Azure Resource Group to create."
  type        = string
}

variable "location" {
  description = "Azure region where the resource group will be created."
  type        = string
}

variable "location_code" {
  description = "Short code for the location (e.g., au, us, eu)."
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, prod, uat)."
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to the resource group."
  type        = map(string)
  default     = {}
}
#Environment
variable "location" {
  description = "Code for target Azure location for deployment e.g. ap-southeast-2."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group where resources will be deployed."
  type        = string
}

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
  default     = "15.10"
}
variable "admin_username" {
  description = "Administrator username for the PostgreSQL Flexible Server."
  type        = string
  default     = "psqladmin"
}
variable "admin_password" {
  description = "Administrator password for the PostgreSQL Flexible Server."
  type        = string
  sensitive   = true
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
  default     = 5120
}
variable "postgresql_flexible_server_tags" {
  description = "Tags to apply to the PostgreSQL Flexible Server."
  type        = map(string)
  default     = {
    environment = "development"
    team        = "database"
  }
}
variable "postgresql_flexible_server_resource_group_name" {
  description = "Name of the resource group where the PostgreSQL Flexible Server will be created."
  type        = string
}
variable "postgresql_flexible_server_location" {
  description = "Azure region where the PostgreSQL Flexible Server will be deployed."
  type        = string
}
variable "postgresql_flexible_server_version" {
  description = "Version of PostgreSQL to use for the Flexible Server."
  type        = string
  default     = "15.10"
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

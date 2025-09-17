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
variable "postgresql_flexible_server_resource_group_name" {
  description = "Name of the resource group where the PostgreSQL Flexible Server will be created."
  type        = string
}
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
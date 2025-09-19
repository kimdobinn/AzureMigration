variable "server_name" {
  description = "Name of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster_identifier."
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name (no AWS equivalent - Azure-specific requirement)."
  type        = string
}

variable "location" {
  description = "Azure region to deploy PostgreSQL Flexible Server (equivalent to AWS region)."
  type        = string
}

variable "postgresql_version" {
  description = "PostgreSQL version. Equivalent to AWS RDS engine_version."
  type        = string
  default     = "15"
  
  validation {
    condition     = contains(["11", "12", "13", "14", "15"], var.postgresql_version)
    error_message = "PostgreSQL version must be one of: 11, 12, 13, 14, 15."
  }
}

variable "administrator_login" {
  description = "Administrator login for the PostgreSQL server. Equivalent to AWS RDS master_user_username."
  type        = string
}

variable "administrator_password" {
  description = "Administrator password for the PostgreSQL server. Equivalent to AWS RDS master_user_password."
  type        = string
  sensitive   = true
}

variable "sku_name" {
  description = "SKU name for the PostgreSQL server. Equivalent to AWS RDS instance_class but different naming convention."
  type        = string
  default     = "B_Standard_B1ms"
}

variable "storage_mb" {
  description = "Storage size in MB for the PostgreSQL server. Azure uses MB, AWS uses GB. Choose from: [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]."
  type        = number
  default     = 32768
  
  validation {
    condition     = contains([32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408], var.storage_mb)
    error_message = "Storage size must be one of the allowed values: [32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4193280, 4194304, 8388608, 16777216, 33553408]."
  }
}

variable "delegated_subnet_id" {
  description = "ID of the subnet to delegate to PostgreSQL Flexible Server. Equivalent to AWS RDS subnet_ids but Azure only needs one."
  type        = string
}

variable "enable_high_availability" {
  description = "Enable high availability for PostgreSQL Flexible Server. Equivalent to AWS RDS Aurora multi-AZ."
  type        = bool
  default     = true
}

variable "high_availability_mode" {
  description = "High availability mode. 'ZoneRedundant' creates standby server in different availability zone."
  type        = string
  default     = "ZoneRedundant"
  
  validation {
    condition     = contains(["ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "High availability mode must be either 'ZoneRedundant' or 'SameZone'."
  }
}

variable "standby_availability_zone" {
  description = "Availability zone for the standby server (only used with ZoneRedundant HA mode)."
  type        = string
  default     = "1"
}

variable "tags" {
  description = "Tags to apply to PostgreSQL Flexible Server resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}

# Note: NSG-related variables removed as network security is now managed by the shared database NSG

variable "virtual_network_id" {
  description = "ID of the virtual network for private DNS zone linking. Required for VNet integration."
  type        = string
}
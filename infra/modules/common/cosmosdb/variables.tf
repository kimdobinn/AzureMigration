variable "account_name" {
  description = "Name of the Cosmos DB account. Equivalent to AWS DocumentDB cluster_identifier."
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name (no AWS equivalent - Azure-specific requirement)."
  type        = string
}

variable "location" {
  description = "Azure region to deploy Cosmos DB (equivalent to AWS region)."
  type        = string
}

variable "database_name" {
  description = "Name of the MongoDB database to create. Should match your application's database name."
  type        = string
  default     = "respiree"
}

# ENGINE AND VERSION CONFIGURATION

variable "mongo_server_version" {
  description = "MongoDB server version for Cosmos DB. AWS DocumentDB 5.0.0 maps to MongoDB 4.2."
  type        = string
  default     = "4.2"  # Closest to AWS DocumentDB 5.0.0 functionality
  
  validation {
    condition     = contains(["3.2", "3.6", "4.0", "4.2"], var.mongo_server_version)
    error_message = "MongoDB server version must be one of: 3.2, 3.6, 4.0, 4.2."
  }
}

# CONSISTENCY AND PERFORMANCE CONFIGURATION

variable "consistency_level" {
  description = "Consistency level for Cosmos DB. 'Session' is equivalent to AWS DocumentDB default behavior."
  type        = string
  default     = "Session"
  
  validation {
    condition     = contains(["BoundedStaleness", "Eventual", "Session", "Strong", "ConsistentPrefix"], var.consistency_level)
    error_message = "Consistency level must be one of: BoundedStaleness, Eventual, Session, Strong, ConsistentPrefix."
  }
}

variable "max_interval_in_seconds" {
  description = "Maximum lag for eventual consistency (only used with BoundedStaleness consistency)."
  type        = number
  default     = 300
}

variable "max_staleness_prefix" {
  description = "Maximum number of stale requests (only used with BoundedStaleness consistency)."
  type        = number
  default     = 100000
}

variable "throughput" {
  description = "Request Units per second for the database. Equivalent to AWS DocumentDB instance sizing."
  type        = number
  default     = 400  # 400 RU/s is roughly equivalent to AWS DocumentDB db.t3.small
}

variable "enable_autoscale" {
  description = "Enable autoscaling for throughput. Alternative to fixed throughput."
  type        = bool
  default     = false
}

variable "max_autoscale_throughput" {
  description = "Maximum throughput for autoscaling (only used if enable_autoscale is true)."
  type        = number
  default     = 4000
}

# HIGH AVAILABILITY CONFIGURATION

variable "enable_zone_redundant" {
  description = "Enable zone redundancy within region. Equivalent to AWS DocumentDB cross-AZ replication."
  type        = bool
  default     = true
}

variable "enable_multi_region" {
  description = "Enable multi-region deployment. Exceeds AWS DocumentDB capabilities (AWS is single-region only)."
  type        = bool
  default     = false  # Keep false to match AWS DocumentDB single-region setup
}

variable "secondary_region" {
  description = "Secondary region for multi-region deployment (only used if enable_multi_region is true)."
  type        = string
  default     = "australiasoutheast"  # Closest region to australiaeast
}

# NETWORK CONFIGURATION

variable "subnet_ids" {
  description = "List of subnet IDs for virtual network integration. Equivalent to AWS DocumentDB subnet_ids."
  type        = list(string)
}

variable "enable_virtual_network_filter" {
  description = "Enable virtual network filtering. Equivalent to AWS VPC placement."
  type        = bool
  default     = true
}

variable "enable_public_network_access" {
  description = "Enable public network access. Set to false for VPC-only access like AWS DocumentDB."
  type        = bool
  default     = false
}

# BACKUP CONFIGURATION

variable "backup_type" {
  description = "Backup type for Cosmos DB. 'Continuous' is equivalent to AWS DocumentDB automated backups."
  type        = string
  default     = "Continuous"
  
  validation {
    condition     = contains(["Continuous", "Periodic"], var.backup_type)
    error_message = "Backup type must be either 'Continuous' or 'Periodic'."
  }
}

variable "backup_tier" {
  description = "Backup tier for continuous backup. Determines point-in-time recovery window."
  type        = string
  default     = "Continuous7Days"
}

variable "backup_interval_minutes" {
  description = "Backup interval in minutes (only used with Periodic backup)."
  type        = number
  default     = 240  # 4 hours
}

variable "backup_retention_hours" {
  description = "Backup retention period in hours. Equivalent to AWS DocumentDB backup retention."
  type        = number
  default     = 168  # 7 days (168 hours)
}

# TAGGING

variable "tags" {
  description = "Tags to apply to Cosmos DB resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}

# NETWORK SECURITY CONFIGURATION

variable "ingress_cidr_block" {
  description = "CIDR block allowed to access Cosmos DB. Equivalent to AWS security group ingress_cidr_blocks."
  type        = string
}
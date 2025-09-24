# Azure Frontend Module Variables - equivalent to AWS frontend variables

# Basic Configuration
variable "resource_name_prefix" {
  description = "Resource name prefix. Equivalent to AWS resource_name_prefix."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group. No AWS equivalent."
  type        = string
}

variable "location" {
  description = "Azure region to deploy resources. Equivalent to AWS region."
  type        = string
}

# Storage Configuration - equivalent to AWS S3 config
variable "storage_config" {
  description = "Configuration for frontend's Storage Account. Equivalent to AWS S3 config."
  type = object({
    replication_type              = string
    public_network_access_enabled = bool
    allow_public_access          = bool
    enable_versioning            = bool
    index_document               = string
    error_404_document           = string
    allowed_origins              = list(string)
    enable_network_rules         = bool
    default_network_action       = string
    allowed_ip_ranges            = list(string)
    allowed_subnet_ids           = list(string)
  })
}

# CDN Configuration - equivalent to AWS CloudFront config
variable "cdn_config" {
  description = "Configuration for frontend's CDN. Equivalent to AWS CloudFront config."
  type = object({
    sku                    = string
    cache_duration         = number
    custom_domain_name     = string
    enable_https          = bool
    minimum_tls_version   = string
    geo_restrictions      = list(string)
    geo_restriction_action = string
  })
}

# Tags
variable "tags" {
  description = "Tags to apply to frontend resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}
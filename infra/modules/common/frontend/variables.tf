# Basic Configuration
variable "storage_account_name" {
  description = "Name of the Azure Storage Account for static website hosting. Equivalent to AWS S3 bucket name."
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name. No AWS equivalent - Azure-specific requirement."
  type        = string
}

variable "location" {
  description = "Azure region for the frontend resources. Equivalent to AWS region."
  type        = string
}

# Storage Account Configuration (equivalent to AWS S3 settings)
variable "replication_type" {
  description = "Storage replication type. LRS=local, GRS=geo-redundant. Equivalent to AWS S3 replication."
  type        = string
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.replication_type)
    error_message = "Replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "public_network_access_enabled" {
  description = "Enable public network access to storage account. Equivalent to AWS S3 public access settings."
  type        = bool
  default     = true
}

variable "allow_public_access" {
  description = "Allow public access to blobs. Equivalent to AWS S3 public read access."
  type        = bool
  default     = true
}

variable "enable_versioning" {
  description = "Enable blob versioning. Equivalent to AWS S3 versioning."
  type        = bool
  default     = true
}

# Static Website Configuration (equivalent to AWS S3 static website hosting)
variable "index_document" {
  description = "Index document for static website. Equivalent to AWS CloudFront default_root_object."
  type        = string
  default     = "index.html"
}

variable "error_404_document" {
  description = "404 error document for static website. Equivalent to AWS CloudFront custom error pages."
  type        = string
  default     = "404.html"
}

variable "allowed_origins" {
  description = "CORS allowed origins for web access. Equivalent to AWS S3 CORS configuration."
  type        = list(string)
  default     = ["*"]
}

# CDN Configuration (equivalent to AWS CloudFront settings)
variable "cdn_profile_name" {
  description = "Name of the Azure CDN profile. Equivalent to AWS CloudFront distribution name."
  type        = string
}

variable "cdn_endpoint_name" {
  description = "Name of the Azure CDN endpoint. Equivalent to AWS CloudFront distribution domain."
  type        = string
}

variable "cdn_sku" {
  description = "Azure CDN SKU. Standard_Microsoft=global, Standard_Akamai=performance. Equivalent to AWS CloudFront price class."
  type        = string
  default     = "Standard_Microsoft"
  
  validation {
    condition     = contains(["Standard_Akamai", "Standard_Microsoft", "Standard_Verizon", "Premium_Verizon"], var.cdn_sku)
    error_message = "CDN SKU must be one of: Standard_Akamai, Standard_Microsoft, Standard_Verizon, Premium_Verizon."
  }
}

variable "cache_duration" {
  description = "Cache duration in ISO 8601 format. Equivalent to AWS CloudFront TTL settings."
  type        = string
  default     = "1.00:00:00"  # 1 day
}

# Custom Domain Configuration (equivalent to AWS CloudFront aliases)
variable "custom_domain_name" {
  description = "Custom domain name for the CDN endpoint. Equivalent to AWS CloudFront aliases."
  type        = string
  default     = null
}

variable "enable_https" {
  description = "Enable HTTPS for custom domain. Equivalent to AWS CloudFront SSL certificate."
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for HTTPS. Equivalent to AWS CloudFront minimum_protocol_version."
  type        = string
  default     = "TLS12"
  
  validation {
    condition     = contains(["TLS10", "TLS12"], var.minimum_tls_version)
    error_message = "Minimum TLS version must be TLS10 or TLS12."
  }
}

# Geo-filtering Configuration (equivalent to AWS CloudFront geo restrictions)
variable "geo_restrictions" {
  description = "List of country codes for geo-filtering. Equivalent to AWS CloudFront geo restrictions."
  type        = list(string)
  default     = []
}

variable "geo_restriction_action" {
  description = "Action for geo-filtering: Allow or Block. Equivalent to AWS CloudFront restriction type."
  type        = string
  default     = "Allow"
  
  validation {
    condition     = contains(["Allow", "Block"], var.geo_restriction_action)
    error_message = "Geo restriction action must be Allow or Block."
  }
}

# Network Security Configuration (equivalent to AWS S3 bucket policy)
variable "enable_network_rules" {
  description = "Enable network access rules for storage account. Equivalent to AWS S3 bucket policy restrictions."
  type        = bool
  default     = false
}

variable "default_network_action" {
  description = "Default network access action: Allow or Deny. Equivalent to AWS S3 bucket policy default action."
  type        = string
  default     = "Allow"
  
  validation {
    condition     = contains(["Allow", "Deny"], var.default_network_action)
    error_message = "Default network action must be Allow or Deny."
  }
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for storage access. Equivalent to AWS S3 bucket policy IP restrictions."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs for storage access. Equivalent to AWS S3 VPC endpoint access."
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "Tags to apply to frontend resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}
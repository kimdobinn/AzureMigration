# Azure Storage Account - equivalent to AWS S3 Bucket
# Provides static website hosting capabilities
resource "azurerm_storage_account" "this" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Storage configuration - equivalent to AWS S3 settings
  account_tier             = "Standard"           # Standard performance tier
  account_replication_type = var.replication_type # LRS, GRS, etc.
  account_kind             = "StorageV2"          # General-purpose v2 (supports static websites)

  # Security configuration - equivalent to AWS S3 public access block
  public_network_access_enabled   = var.public_network_access_enabled
  allow_nested_items_to_be_public = var.allow_public_access

  # Static website configuration - equivalent to AWS S3 static website hosting
  # Note: static_website block is configured separately via azurerm_storage_account_static_website resource

  # Blob properties for versioning - equivalent to AWS S3 versioning
  blob_properties {
    versioning_enabled = var.enable_versioning

    # CORS configuration for web access - equivalent to AWS S3 CORS
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "OPTIONS"]
      allowed_origins    = var.allowed_origins
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  tags = merge(
    var.tags,
    {
      Name         = var.storage_account_name
      Service      = "StaticWebsite"
      MigratedFrom = "AWS-S3-StaticWebsite"
    }
  )
}

# Azure CDN Profile - equivalent to AWS CloudFront Distribution
# Provides global content delivery network capabilities
resource "azurerm_cdn_profile" "this" {
  name                = var.cdn_profile_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # CDN SKU - equivalent to AWS CloudFront price class
  # Standard_Microsoft = AWS CloudFront PriceClass_All
  # Standard_Akamai = AWS CloudFront PriceClass_100  
  # Premium_Verizon = AWS CloudFront PriceClass_200
  sku = var.cdn_sku

  tags = merge(
    var.tags,
    {
      Name         = var.cdn_profile_name
      Service      = "CDN"
      MigratedFrom = "AWS-CloudFront"
    }
  )
}

# Azure CDN Endpoint - equivalent to AWS CloudFront Distribution configuration
# Connects the CDN to the storage account origin
resource "azurerm_cdn_endpoint" "this" {
  name                = var.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Origin configuration - equivalent to AWS CloudFront origin
  origin {
    name      = "storage-origin"
    host_name = azurerm_storage_account.this.primary_web_host # Static website endpoint
  }

  # Caching behavior - equivalent to AWS CloudFront cache behaviors
  delivery_rule {
    name  = "httpsredirect"
    order = 1

    request_scheme_condition {
      operator     = "Equal"
      match_values = ["HTTP"]
    }

    url_redirect_action {
      redirect_type = "PermanentRedirect"
      protocol      = "Https"
    }
  }

  # Global delivery rule for caching - equivalent to AWS CloudFront default cache behavior
  global_delivery_rule {
    cache_expiration_action {
      behavior = "Override"
      duration = var.cache_duration # Equivalent to AWS CloudFront TTL settings
    }

    cache_key_query_string_action {
      behavior = "IncludeAll" # Include query strings in cache key
    }
  }

  # Geo-filtering - equivalent to AWS CloudFront geo restrictions
  dynamic "geo_filter" {
    for_each = length(var.geo_restrictions) > 0 ? [1] : []
    content {
      relative_path = "/*"
      action        = var.geo_restriction_action # Allow or Block
      country_codes = var.geo_restrictions
    }
  }

  # Optimization - equivalent to AWS CloudFront optimization
  optimization_type = "GeneralWebDelivery" # Optimized for web content

  tags = merge(
    var.tags,
    {
      Name         = var.cdn_endpoint_name
      Service      = "CDN-Endpoint"
      MigratedFrom = "AWS-CloudFront-Distribution"
    }
  )
}

# Custom Domain for CDN - equivalent to AWS CloudFront aliases
# Allows using custom domain instead of Azure CDN domain
resource "azurerm_cdn_endpoint_custom_domain" "this" {
  count           = var.custom_domain_name != null ? 1 : 0
  name            = replace(var.custom_domain_name, ".", "-")
  cdn_endpoint_id = azurerm_cdn_endpoint.this.id
  host_name       = var.custom_domain_name

  # HTTPS configuration - equivalent to AWS CloudFront viewer certificate
  dynamic "cdn_managed_https" {
    for_each = var.enable_https ? [1] : []
    content {
      certificate_type = "Dedicated" # Dedicated certificate for custom domain
      protocol_type    = "ServerNameIndication"
      tls_version      = var.minimum_tls_version # Equivalent to AWS minimum_protocol_version
    }
  }
}

# Static Website Configuration - equivalent to AWS S3 static website hosting
# Enables static website hosting on the storage account
resource "azurerm_storage_account_static_website" "this" {
  storage_account_id = azurerm_storage_account.this.id
  index_document     = var.index_document     # Equivalent to CloudFront default_root_object
  error_404_document = var.error_404_document # Custom error page
}

# Storage Container for web content - equivalent to AWS S3 bucket content
# This is where the static website files will be stored
resource "azurerm_storage_container" "web" {
  name                  = "$web" # Special container name for static websites
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "blob" # Allow public read access to blobs
}

# Network Security - equivalent to AWS S3 bucket policy
# Controls access to the storage account
resource "azurerm_storage_account_network_rules" "this" {
  count              = var.enable_network_rules ? 1 : 0
  storage_account_id = azurerm_storage_account.this.id

  default_action = var.default_network_action # Allow or Deny

  # IP rules - equivalent to AWS S3 bucket policy IP restrictions
  ip_rules = var.allowed_ip_ranges

  # Virtual network rules - equivalent to AWS S3 VPC endpoint access
  virtual_network_subnet_ids = var.allowed_subnet_ids
}

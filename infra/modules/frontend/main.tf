# Local variables for naming
locals {
  storage_account_name = "${replace(var.resource_name_prefix, "-", "")}staticweb"
  cdn_profile_name     = "${var.resource_name_prefix}-cdn-profile"
  cdn_endpoint_name    = "${var.resource_name_prefix}-cdn-endpoint"
}

# Azure Storage Account - equivalent to AWS S3 Bucket
# Provides static website hosting capabilities
resource "azurerm_storage_account" "this" {
  name                = local.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # Storage configuration - equivalent to AWS S3 settings
  account_tier             = "Standard"                          # Standard performance tier
  account_replication_type = var.storage_config.replication_type # LRS, GRS, etc.
  account_kind             = "StorageV2"                         # General-purpose v2 (supports static websites)

  # Security configuration - equivalent to AWS S3 public access block
  public_network_access_enabled   = var.storage_config.public_network_access_enabled
  allow_nested_items_to_be_public = var.storage_config.allow_public_access

  # Blob properties for versioning - equivalent to AWS S3 versioning
  blob_properties {
    versioning_enabled = var.storage_config.enable_versioning

    # CORS configuration - equivalent to AWS S3 CORS
    cors_rule {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "HEAD", "OPTIONS"]
      allowed_origins    = var.storage_config.allowed_origins
      exposed_headers    = ["*"]
      max_age_in_seconds = 3600
    }
  }

  # Network access rules - equivalent to AWS S3 VPC endpoints
  dynamic "network_rules" {
    for_each = var.storage_config.enable_network_rules ? [1] : []
    content {
      default_action             = var.storage_config.default_network_action
      ip_rules                   = var.storage_config.allowed_ip_ranges
      virtual_network_subnet_ids = var.storage_config.allowed_subnet_ids
    }
  }

  tags = merge(
    var.tags,
    {
      Name         = local.storage_account_name
      Service      = "StaticWebsite"
      MigratedFrom = "AWS-S3-StaticWebsite"
    }
  )
}

# Static website configuration - equivalent to AWS S3 static website hosting
resource "azurerm_storage_account_static_website" "this" {
  storage_account_id = azurerm_storage_account.this.id
  index_document     = var.storage_config.index_document
  error_404_document = var.storage_config.error_404_document
}

# Web container for static files - equivalent to AWS S3 bucket content
resource "azurerm_storage_container" "web" {
  name                  = "$web"
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "blob" # Public read access for web files
}

# CDN Profile - equivalent to AWS CloudFront Distribution (container)
resource "azurerm_cdn_profile" "this" {
  name                = local.cdn_profile_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.cdn_config.sku

  tags = merge(
    var.tags,
    {
      Name         = local.cdn_profile_name
      Service      = "CDN"
      MigratedFrom = "AWS-CloudFront"
    }
  )
}

# CDN Endpoint - equivalent to AWS CloudFront Distribution (actual CDN)
resource "azurerm_cdn_endpoint" "this" {
  name                = local.cdn_endpoint_name
  profile_name        = azurerm_cdn_profile.this.name
  location            = var.location
  resource_group_name = var.resource_group_name

  # Origin configuration - equivalent to AWS CloudFront origin
  origin {
    name      = "storage-origin"
    host_name = azurerm_storage_account.this.primary_web_host
  }

  # HTTPS configuration - equivalent to AWS CloudFront viewer protocol policy
  is_https_allowed = var.cdn_config.enable_https
  is_http_allowed  = !var.cdn_config.enable_https

  # Caching configuration - equivalent to AWS CloudFront cache behaviors
  global_delivery_rule {
    cache_expiration_action {
      behavior = "Override"
      duration = format("%02d:%02d:%02d", floor(var.cdn_config.cache_duration / 3600), floor((var.cdn_config.cache_duration % 3600) / 60), var.cdn_config.cache_duration % 60)
    }

    # HTTPS redirect - equivalent to AWS CloudFront redirect-to-https
    url_redirect_action {
      redirect_type = "PermanentRedirect"
      protocol      = "Https"
    }
  }

  # Custom cache rules - equivalent to AWS CloudFront ordered_cache_behavior
  delivery_rule {
    name  = "notifyjscache"
    order = 1

    url_path_condition {
      operator     = "Equal"
      match_values = ["/notify.js"]
    }

    cache_expiration_action {
      behavior = "Override"
      duration = "01:00:00" # 1 hour in hh:mm:ss format
    }
  }

  delivery_rule {
    name  = "redirectjscache"
    order = 2

    url_path_condition {
      operator     = "Equal"
      match_values = ["/redirect.js"]
    }

    cache_expiration_action {
      behavior = "Override"
      duration = "01:00:00" # 1 hour in hh:mm:ss format
    }
  }

  delivery_rule {
    name  = "firebaseswcache"
    order = 3

    url_path_condition {
      operator     = "Equal"
      match_values = ["/firebase-messaging-sw.js"]
    }

    cache_expiration_action {
      behavior = "Override"
      duration = "01:00:00" # 1 hour in hh:mm:ss format
    }
  }

  # Geo-filtering - equivalent to AWS CloudFront geo restrictions
  dynamic "geo_filter" {
    for_each = length(var.cdn_config.geo_restrictions) > 0 ? [1] : []
    content {
      relative_path = "/*"
      action        = var.cdn_config.geo_restriction_action
      country_codes = var.cdn_config.geo_restrictions
    }
  }

  tags = merge(
    var.tags,
    {
      Name         = local.cdn_endpoint_name
      Service      = "CDN-Endpoint"
      MigratedFrom = "AWS-CloudFront-Distribution"
    }
  )
}

# Custom domain configuration - equivalent to AWS CloudFront aliases
resource "azurerm_cdn_endpoint_custom_domain" "this" {
  count           = var.cdn_config.custom_domain_name != null && var.cdn_config.custom_domain_name != "" ? 1 : 0
  name            = replace(var.cdn_config.custom_domain_name, ".", "-")
  cdn_endpoint_id = azurerm_cdn_endpoint.this.id
  host_name       = var.cdn_config.custom_domain_name

  # HTTPS configuration - equivalent to AWS CloudFront SSL certificate
  dynamic "cdn_managed_https" {
    for_each = var.cdn_config.enable_https ? [1] : []
    content {
      certificate_type = "Dedicated"
      protocol_type    = "ServerNameIndication"
      tls_version      = var.cdn_config.minimum_tls_version
    }
  }
}

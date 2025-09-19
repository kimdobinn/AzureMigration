# Azure Frontend - equivalent to AWS S3 + CloudFront
module "frontend" {
  source = "../../../modules/common/frontend"

  # Basic configuration
  storage_account_name = "${replace(local.resource_name_prefix, "-", "")}staticweb"
  resource_group_name  = module.resource_group.resource_group_name
  location            = var.location

  # Storage configuration - equivalent to AWS S3
  replication_type              = var.frontend_replication_type
  public_network_access_enabled = var.frontend_public_network_access
  allow_public_access          = var.frontend_allow_public_access
  enable_versioning            = var.frontend_enable_versioning

  # Static website configuration
  index_document     = var.frontend_index_document
  error_404_document = var.frontend_error_404_document
  allowed_origins    = var.frontend_allowed_origins

  # CDN configuration - equivalent to AWS CloudFront
  cdn_profile_name  = "${local.resource_name_prefix}-cdn-profile"
  cdn_endpoint_name = "${local.resource_name_prefix}-cdn-endpoint"
  cdn_sku          = var.frontend_cdn_sku
  cache_duration   = var.frontend_cache_duration
  
  # Custom domain and HTTPS
  custom_domain_name   = var.frontend_custom_domain_name
  enable_https        = var.frontend_enable_https
  minimum_tls_version = var.frontend_minimum_tls_version

  # Geo-filtering - equivalent to AWS CloudFront geo restrictions
  geo_restrictions       = var.frontend_geo_restrictions
  geo_restriction_action = var.frontend_geo_restriction_action

  # Network security
  enable_network_rules   = var.frontend_enable_network_rules
  default_network_action = var.frontend_default_network_action
  allowed_ip_ranges      = var.frontend_allowed_ip_ranges
  allowed_subnet_ids     = var.frontend_allowed_subnet_ids

  tags = {
    Environment  = var.environment
    MigratedFrom = "AWS-S3-CloudFront"
  }
}
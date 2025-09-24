# Azure Frontend - equivalent to AWS S3 + CloudFront
module "frontend" {
  source = "../../../modules/frontend"

  # Basic configuration
  resource_name_prefix = local.resource_name_prefix
  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location

  # Storage configuration - equivalent to AWS S3
  storage_config = var.frontend_storage_config

  # CDN configuration - equivalent to AWS CloudFront
  cdn_config = var.frontend_cdn_config

  tags = {
    Environment  = var.environment
    MigratedFrom = "AWS-S3-CloudFront"
  }
}

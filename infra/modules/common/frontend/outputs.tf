# Storage Account Outputs (equivalent to AWS S3 bucket outputs)
output "storage_account_id" {
  description = "The ID of the storage account. Equivalent to AWS S3 bucket ARN."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "The name of the storage account. Equivalent to AWS S3 bucket name."
  value       = azurerm_storage_account.this.name
}

output "primary_web_endpoint" {
  description = "Primary web endpoint for static website. Equivalent to AWS S3 website endpoint."
  value       = azurerm_storage_account.this.primary_web_endpoint
}

output "primary_web_host" {
  description = "Primary web host for static website. Used as CDN origin."
  value       = azurerm_storage_account.this.primary_web_host
}

# CDN Outputs (equivalent to AWS CloudFront outputs)
output "cdn_profile_id" {
  description = "The ID of the CDN profile. Equivalent to AWS CloudFront distribution ID."
  value       = azurerm_cdn_profile.this.id
}

output "cdn_endpoint_id" {
  description = "The ID of the CDN endpoint. Equivalent to AWS CloudFront distribution ID."
  value       = azurerm_cdn_endpoint.this.id
}

output "cdn_endpoint_hostname" {
  description = "The hostname of the CDN endpoint. Equivalent to AWS CloudFront domain name."
  value       = azurerm_cdn_endpoint.this.fqdn
}

output "cdn_endpoint_fqdn" {
  description = "The FQDN of the CDN endpoint. Equivalent to AWS CloudFront distribution domain name."
  value       = azurerm_cdn_endpoint.this.fqdn
}

# Custom Domain Outputs (equivalent to AWS CloudFront aliases)
output "custom_domain_name" {
  description = "The custom domain name configured for the CDN. Equivalent to AWS CloudFront aliases."
  value       = var.custom_domain_name
}

output "custom_domain_fqdn" {
  description = "The FQDN of the custom domain (if configured)."
  value       = var.custom_domain_name != null ? "https://${var.custom_domain_name}" : null
}

# Website URLs for easy access
output "website_urls" {
  description = "Website URLs for accessing the frontend. Equivalent to AWS S3 + CloudFront URLs."
  value = {
    storage_endpoint = azurerm_storage_account.this.primary_web_endpoint
    cdn_endpoint     = "https://${azurerm_cdn_endpoint.this.fqdn}"
    custom_domain    = var.custom_domain_name != null ? "https://${var.custom_domain_name}" : null
  }
}

# Storage Container Output
output "web_container_name" {
  description = "Name of the web container for static files. Equivalent to AWS S3 bucket for web content."
  value       = azurerm_storage_container.web.name
}

# Connection Information for CI/CD
output "deployment_info" {
  description = "Information needed for deploying static files. Equivalent to AWS S3 deployment details."
  value = {
    storage_account_name = azurerm_storage_account.this.name
    container_name       = azurerm_storage_container.web.name
    cdn_endpoint_name    = azurerm_cdn_endpoint.this.name
    cdn_profile_name     = azurerm_cdn_profile.this.name
    resource_group_name  = var.resource_group_name
  }
}
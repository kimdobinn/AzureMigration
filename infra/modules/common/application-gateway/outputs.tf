# Azure Application Gateway Module Outputs - equivalent to AWS ALB outputs

# Application Gateway Outputs
output "id" {
  description = "The ID of the Application Gateway. Equivalent to AWS ALB ID."
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "The name of the Application Gateway. Equivalent to AWS ALB name."
  value       = azurerm_application_gateway.this.name
}

output "public_ip_address" {
  description = "The public IP address of the Application Gateway. Equivalent to AWS ALB DNS name."
  value       = azurerm_public_ip.this.ip_address
}

output "fqdn" {
  description = "The FQDN of the Application Gateway public IP. Equivalent to AWS ALB DNS name."
  value       = azurerm_public_ip.this.fqdn
}

# For compatibility with existing code (event-scheduler expects this)
output "endpoint" {
  description = "The endpoint URL for the Application Gateway. Used by event-scheduler."
  value       = azurerm_public_ip.this.fqdn != null ? azurerm_public_ip.this.fqdn : azurerm_public_ip.this.ip_address
}

# Backend Pool Information
output "backend_address_pool_id" {
  description = "The ID of the backend address pool."
  value       = tolist(azurerm_application_gateway.this.backend_address_pool)[0].id
}

# Network Information
output "subnet_id" {
  description = "The subnet ID where the Application Gateway is deployed."
  value       = var.subnet_id
}

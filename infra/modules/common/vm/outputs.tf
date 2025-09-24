# Azure Common VM Module Outputs - equivalent to AWS common/ec2 outputs

# VM Outputs
output "id" {
  description = "The ID of the VM. Equivalent to AWS instance ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "The name of the VM. Equivalent to AWS instance name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip_address" {
  description = "The private IP address of the VM. Equivalent to AWS instance private IP."
  value       = azurerm_network_interface.this.private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the VM (if assigned)."
  value       = null  # No public IP by default
}

# Network Outputs
output "network_interface_id" {
  description = "The ID of the network interface."
  value       = azurerm_network_interface.this.id
}

output "network_security_group_id" {
  description = "The ID of the network security group."
  value       = azurerm_network_security_group.this.id
}

# For compatibility with existing code
output "endpoint" {
  description = "The private IP endpoint of the VM (alias for private_ip_address)."
  value       = azurerm_network_interface.this.private_ip_address
}

output "port" {
  description = "Placeholder for port (services define their own ports)."
  value       = null
}
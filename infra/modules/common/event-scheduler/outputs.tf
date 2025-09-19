# Azure Event-Scheduler Module Outputs - equivalent to AWS event-scheduler outputs

# VM Outputs (equivalent to AWS EC2 outputs)
output "id" {
  description = "The ID of the event-scheduler VM. Equivalent to AWS instance ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "The name of the event-scheduler VM. Equivalent to AWS instance name."
  value       = azurerm_linux_virtual_machine.this.name
}

output "endpoint" {
  description = "The private IP endpoint of the event-scheduler VM. Equivalent to AWS instance private IP."
  value       = azurerm_network_interface.this.private_ip_address
}

output "port" {
  description = "The port number that event-scheduler service listens on. Same as AWS."
  value       = var.event_scheduler.port
}

# Additional Azure-specific outputs
output "public_ip_address" {
  description = "The public IP address of the event-scheduler VM (if assigned)."
  value       = null  # No public IP assigned by default
}

output "network_security_group_id" {
  description = "The ID of the network security group associated with the VM."
  value       = azurerm_network_security_group.this.id
}

output "private_ip_address" {
  description = "The private IP address of the event-scheduler VM."
  value       = azurerm_network_interface.this.private_ip_address
}

# Connection Information for Backend Integration
output "connection_info" {
  description = "Connection information for backend services to communicate with event-scheduler."
  value = {
    host     = azurerm_network_interface.this.private_ip_address
    port     = var.event_scheduler.port
    endpoint = "${azurerm_network_interface.this.private_ip_address}:${var.event_scheduler.port}"
  }
}
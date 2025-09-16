output "id" {
  description = "The ID of the virtual machine."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "The name of the virtual machine."
  value       = azurerm_linux_virtual_machine.this.name
}

output "private_ip" {
  description = "The private IP address assigned to the VM."
  value       = azurerm_linux_virtual_machine.this.private_ip_address
}

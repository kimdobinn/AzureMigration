output "vnet_id" {
  description = "ID of the VNet (equivalent to AWS VPC ID)"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the VNet"
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "Address space of the VNet (equivalent to AWS VPC CIDR)"
  value       = azurerm_virtual_network.this.address_space
}

# Public Subnet Outputs - equivalent to AWS public subnet outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in azurerm_subnet.dynamic_public_subnets : subnet.id]
}

output "public_subnet_names" {
  description = "Names of the public subnets"
  value       = [for subnet in azurerm_subnet.dynamic_public_subnets : subnet.name]
}

# Private Subnet Outputs - equivalent to AWS private subnet outputs
output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in azurerm_subnet.dynamic_private_subnets : subnet.id]
}

output "private_subnet_names" {
  description = "Names of the private subnets"
  value       = [for subnet in azurerm_subnet.dynamic_private_subnets : subnet.name]
}

# NAT Gateway Outputs - equivalent to AWS NAT Gateway outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = azurerm_nat_gateway.nat_gw.id
}

output "nat_public_ip" {
  description = "Public IP address of the NAT Gateway"
  value       = azurerm_public_ip.nat.ip_address
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = azurerm_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = azurerm_route_table.private_rt.id
}

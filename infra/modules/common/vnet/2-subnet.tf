resource "azurerm_subnet" "dynamic_public_subnets" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }

  name                 = "${var.resource_name_prefix}-${each.value.name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]

  # In Azure, can't directly assign AZ like AWS. Instead, can use zones for VM placement later
  # The use_alternate_az flag will be used when creating resources in these subnets
}

# Private subnets to route through NAT Gateway for outbound internet access
resource "azurerm_subnet" "dynamic_private_subnets" {
  for_each = { for idx, subnet in var.private_subnets : idx => subnet }

  name                 = "${var.resource_name_prefix}-${each.value.name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]

  # Private subnets delegate to services like PostgreSQL. Same as AWS RDS subnet groups
  delegation {
    name = "postgresql-delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

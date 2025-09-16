# Route Table for Public Subnets
# Azure public subnets get internet access by default, but it's recommended that we 
# create explicit route table for consistency.
# Similar to AWS IGW route table, but Azure handles internet routing automatically
# Azure doesn't need explicit internet route like AWS (0.0.0.0/0 -> IGW)
resource "azurerm_route_table" "public_rt" {
  name                = "${var.resource_name_prefix}-public-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = {
    Name = "${var.resource_name_prefix}-public-rt"
  }
}

# Associate Route Table with Public Subnets
resource "azurerm_subnet_route_table_association" "dynamic_public_subnet_rt_assoc" {
  for_each = { for idx, subnet in azurerm_subnet.dynamic_public_subnets : idx => subnet }

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.public_rt.id
}

# Route Table for Private Subnets
# Azure NAT Gateway is associated directly with subnets, not through route tables
# Azure NAT Gateway handles 0.0.0.0/0 routing automatically when associated with subnet
# Don't need explicit route entries for NAT Gateway traffic

resource "azurerm_route_table" "private_rt" {
  name                = "${var.resource_name_prefix}-private-rt"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = {
    Name = "${var.resource_name_prefix}-private-rt"
  }
}

# Associate Route Table with Private Subnets
resource "azurerm_subnet_route_table_association" "dynamic_private_subnet_rt_assoc" {
  for_each = { for idx, subnet in azurerm_subnet.dynamic_private_subnets : idx => subnet }

  subnet_id      = each.value.id
  route_table_id = azurerm_route_table.private_rt.id
}

# Associate NAT Gateway with Private Subnets
# Azure requires explicit NAT Gateway association with subnets
resource "azurerm_subnet_nat_gateway_association" "private_nat_association" {
  for_each = { for idx, subnet in azurerm_subnet.dynamic_private_subnets : idx => subnet }

  subnet_id      = each.value.id
  nat_gateway_id = azurerm_nat_gateway.nat_gw.id
}

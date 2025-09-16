# Need NAT Gateways for private subnet outbound access

# Public IP for NAT Gateway = AWS Elastic IP for NAT Gateway
# Azure requires explicit public IP resource. For AWS Elastic IP, it's created inline
resource "azurerm_public_ip" "nat" {
  name                = "${var.resource_name_prefix}-nat-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Name = "${var.resource_name_prefix}-nat-pip"
  }
}

# NAT Gateway = AWS NAT Gateway
# Provides outbound internet access for private subnets. Same thing as AWS NAT Gateway
resource "azurerm_nat_gateway" "nat_gw" {
  name                    = "${var.resource_name_prefix}-nat-gw"
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10

  tags = {
    Name = "${var.resource_name_prefix}-nat-gw"
  }
}

# Associate Public IP with NAT Gateway
# Azure requires separate association, AWS does this automatically with allocation_id
resource "azurerm_nat_gateway_public_ip_association" "nat" {
  nat_gateway_id       = azurerm_nat_gateway.nat_gw.id
  public_ip_address_id = azurerm_public_ip.nat.id
}

# Azure VNet has implicit Internet Gateway functionality
# Unlike AWS, we don't need to create an explicit Internet Gateway resource
# Public subnets get internet access automatically through Azure's infrastructure
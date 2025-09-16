resource "azurerm_virtual_network" "this" {
  name                = "${var.resource_name_prefix}-vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space  # Azure address_space = AWS VPC CIDR block

  # DNS support is enabled by default (= AWS enable_dns_support & enable_dns_hostnames)

  tags = {
    Name = "${var.resource_name_prefix}-vnet"
  }
}


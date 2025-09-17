resource "azurerm_postgresql_flexible_server" "this" {
  name                   = var.server_name                    # Equivalent to AWS cluster_identifier
  resource_group_name    = var.resource_group_name            # Azure concept - no AWS equivalent
  location               = var.location                       # Equivalent to AWS region
  version                = var.postgresql_version             # Matches AWS engine_version (15.10)
  administrator_login    = var.administrator_login            # Matches AWS master_user_username
  administrator_password = var.administrator_password         # Matches AWS master_user_password

  # Compute and storage configuration
  sku_name   = var.sku_name   # ~= AWS instance_class
  storage_mb = var.storage_mb # choose from: [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]

  delegated_subnet_id = var.delegated_subnet_id # Connects to specified database subnet

  dynamic "high_availability" {
    for_each = var.enable_high_availability ? [1] : []
    content {
      mode                      = var.high_availability_mode # Creates standby server in different availability zone
      standby_availability_zone = var.standby_availability_zone # Standby in specified AZ
    }
  }

  tags = merge(
    var.tags,
    {
      Name         = var.server_name
      Service      = "PostgreSQL"
      MigratedFrom = "AWS-RDS-Aurora"
    }
  )
}
# This replaces the AWS security group that was attached to your RDS cluster
# Each database module creates its own NSG (matches AWS pattern)
resource "azurerm_network_security_group" "this" {
  name                = "${var.server_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Tags for resource management (equivalent to AWS tags)
  tags = merge(
    var.tags,
    {
      Name         = "${var.server_name}-nsg"
      Service      = "PostgreSQL-Security"
      MigratedFrom = "AWS-SecurityGroup"
    }
  )
}

# Security rule for PostgreSQL access from specified CIDR blocks
# Equivalent to AWS security group ingress rule
resource "azurerm_network_security_rule" "postgresql_ingress" {
  name                        = "Allow-PostgreSQL-Ingress"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5432"                           # PostgreSQL default port
  source_address_prefix       = var.ingress_cidr_block           # Equivalent to AWS ingress_cidr_blocks
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Associate NSG with the database subnets
# Equivalent to AWS security group attachment to RDS
resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = length(var.subnet_ids)
  subnet_id                 = var.subnet_ids[count.index]
  network_security_group_id = azurerm_network_security_group.this.id
}
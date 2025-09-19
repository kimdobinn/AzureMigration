# Private DNS Zone for PostgreSQL Flexible Server
# Required when using VNet integration (delegated subnet)
resource "azurerm_private_dns_zone" "postgresql" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    {
      Name         = "${var.server_name}-private-dns"
      Service      = "PostgreSQL-DNS"
      MigratedFrom = "AWS-RDS-Aurora"
    }
  )
}

# Link the private DNS zone to the VNet
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql" {
  name                  = "${var.server_name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.postgresql.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false

  tags = merge(
    var.tags,
    {
      Name         = "${var.server_name}-dns-link"
      Service      = "PostgreSQL-DNS-Link"
      MigratedFrom = "AWS-RDS-Aurora"
    }
  )
}

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

  delegated_subnet_id           = var.delegated_subnet_id # Connects to specified database subnet
  private_dns_zone_id           = azurerm_private_dns_zone.postgresql.id # Required for VNet integration
  public_network_access_enabled = false # Must be false when using VNet integration

  dynamic "high_availability" {
    for_each = var.enable_high_availability ? [1] : []
    content {
      mode = var.high_availability_mode # Creates standby server in different availability zone
      # Let Azure automatically choose the standby AZ (removed explicit AZ specification)
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
# Note: Network security is managed by the shared database NSG in the CosmosDB module
# Both PostgreSQL and CosmosDB use the same database subnets and share the same NSG
# This matches the AWS pattern where both services would use the same security group
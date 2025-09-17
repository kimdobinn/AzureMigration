resource "azurerm_cosmosdb_account" "this" {
  name                = var.account_name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  offer_type = "Standard"  # Standard pricing tier (equivalent to AWS on-demand pricing)
  kind       = "MongoDB"   # MongoDB API - provides DocumentDB compatibility
  
  mongo_server_version = var.mongo_server_version

  consistency_policy {
    consistency_level       = var.consistency_level        # Equivalent to AWS DocumentDB default behavior
    max_interval_in_seconds = var.max_interval_in_seconds  # Maximum lag for eventual consistency
    max_staleness_prefix    = var.max_staleness_prefix     # Maximum number of stale requests
  }

  # High Availability Configuration - Multi-region setup
  geo_location {
    location          = var.location              # Primary region
    failover_priority = 0                         # Primary region (lowest priority number)
    zone_redundant    = var.enable_zone_redundant # Enable AZ redundancy within region (matches AWS cross-AZ)
  }

  # Enable virtual network integration (equivalent to AWS VPC placement)
  is_virtual_network_filter_enabled = var.enable_virtual_network_filter
  
  # Virtual network rules - equivalent to AWS subnet_ids configuration
  # AWS DocumentDB was placed in both db_main and db_alt subnets
  # Azure Cosmos DB can access from both database subnets
  dynamic "virtual_network_rule" {
    for_each = var.subnet_ids
    content {
      id                                   = virtual_network_rule.value
      ignore_missing_vnet_service_endpoint = false
    }
  }

  # Backup configuration
  # AWS DocumentDB: Automated backups with point-in-time recovery
  # Azure Cosmos DB: Continuous backup with point-in-time restore
  backup {
    type                = var.backup_type                # Equivalent to AWS automated backups
    tier                = var.backup_tier                # Point-in-time recovery window
    interval_in_minutes = var.backup_interval_minutes    # Backup frequency
    retention_in_hours  = var.backup_retention_hours     # Backup retention period
  }

  # Security configuration
  # Disable public network access - equivalent to AWS VPC-only access
  public_network_access_enabled = var.enable_public_network_access

  # Automatic failover configuration
  # Since we only have one geo_location by default, failover happens within availability zones automatically
  # Multi-write locations would require multiple geo_location blocks (not needed for AWS DocumentDB parity)

  # Tags for resource management (equivalent to AWS tags)
  tags = merge(
    var.tags,
    {
      Name         = var.account_name
      Service      = "DocumentDatabase"
      MigratedFrom = "AWS-DocumentDB"
    }
  )
}

resource "azurerm_cosmosdb_mongo_database" "this" {
  # Database identification
  name                = var.database_name                    # Match your application's database name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name   # Reference to the Cosmos DB account created above

  # Throughput configuration
  # AWS DocumentDB: Instance-based pricing (db.t3.medium)
  # Azure Cosmos DB: Request Unit (RU/s) based pricing
  # 400 RU/s is roughly equivalent to a small AWS DocumentDB instance for development
  throughput = var.throughput  # Configurable throughput

  # Note: You can also use autoscale_settings instead of fixed throughput
  # This would be configured through variables if needed
  dynamic "autoscale_settings" {
    for_each = var.enable_autoscale ? [1] : []
    content {
      max_throughput = var.max_autoscale_throughput
    }
  }
}

resource "azurerm_network_security_group" "this" {
  name                = "${var.account_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    {
      Name         = "${var.account_name}-nsg"
      Service      = "DocumentDatabase-Security"
      MigratedFrom = "AWS-SecurityGroup"
    }
  )
}

# Security rule for MongoDB/DocumentDB access from specified CIDR blocks
# Equivalent to AWS security group ingress rule
resource "azurerm_network_security_rule" "mongodb_ingress" {
  name                        = "Allow-MongoDB-Ingress"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "27017"                          # MongoDB default port (DocumentDB compatible)
  source_address_prefix       = var.ingress_cidr_block           # Equivalent to AWS ingress_cidr_blocks
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Associate NSG with the database subnets
# Equivalent to AWS security group attachment to DocumentDB
resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = length(var.subnet_ids)
  subnet_id                 = var.subnet_ids[count.index]
  network_security_group_id = azurerm_network_security_group.this.id
}
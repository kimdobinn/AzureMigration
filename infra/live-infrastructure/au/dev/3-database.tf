module "postgresql" {
  source                 = "../../../modules/common/pgflex"
  server_name            = "${local.resource_name_prefix}-pgflex"        # Equivalent to AWS cluster_identifier
  resource_group_name    = var.resource_group_name                       # Azure concept - no AWS equivalent
  location               = var.location                                  # Equivalent to AWS region
  postgresql_version     = var.postgresql_version                        # Matches AWS engine_version (15.10)
  administrator_login    = var.postgresql_flexible_server_admin_username # Matches AWS master_user_username
  administrator_password = var.postgresql_flexible_server_admin_password # Matches AWS master_user_password

  sku_name   = var.postgresql_flexible_server_sku_name   # Equivalent to AWS instance_class, but different naming
  storage_mb = var.postgresql_flexible_server_storage_mb # Azure uses MB, AWS uses GB - choose from: [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]

  # Network configuration - connects to private database subnets
  # This is equivalent to AWS subnet_ids but Azure only needs one subnet ID
  # Azure automatically handles cross-AZ placement for HA
  delegated_subnet_id = module.vnet.private_subnet_ids[1] # Connects to db_main subnet (index [1])

  # High Availability Configuration - matches AWS RDS Aurora setup
  # AWS Aurora: Automatically creates read replicas across AZs
  # Azure: Explicitly enable zone-redundant HA with standby server
  enable_high_availability  = true            # Enable HA (matches your current setup)
  high_availability_mode    = "ZoneRedundant" # Creates standby server in different availability zone
  standby_availability_zone = "2"             # Standby in AZ 2 (primary will be in AZ 1)
  # This matches your db_alt subnet being in alternate AZ

  # Network Security Configuration - equivalent to AWS RDS security group
  ingress_cidr_block = var.app_address_space # Allow access from app subnet (matches AWS pattern)
  subnet_ids = [
    module.vnet.private_subnet_ids[1], # db_main subnet
    module.vnet.private_subnet_ids[2]  # db_alt subnet
  ]

  # Tags for resource management (equivalent to AWS tags)
  tags = {
    Environment  = var.environment
    MigratedFrom = "AWS-RDS-Aurora"
  }
}

# This module creates Azure Cosmos DB with MongoDB API to replace AWS DocumentDB
# Uses the common/cosmosdb module for reusability across environments
module "cosmosdb" {
  source = "../../../modules/common/cosmosdb"

  # Basic configuration - matches AWS DocumentDB cluster settings
  account_name        = "${local.resource_name_prefix}-cosmos-docdb" # Equivalent to AWS cluster_identifier
  resource_group_name = var.resource_group_name                      # Azure concept - no AWS equivalent
  location            = var.location                                 # Primary region - equivalent to AWS region
  database_name       = "respiree"                                   # Match your application's database name

  # Engine configuration - matches AWS DocumentDB 5.0.0
  mongo_server_version = "4.2" # Closest to AWS DocumentDB 5.0.0 functionality

  # Performance configuration - equivalent to AWS DocumentDB instance sizing
  throughput = var.cosmosdb_mongo_throughput # 400 RU/s ≈ AWS DocumentDB db.t3.small

  # High Availability configuration - matches AWS DocumentDB cross-AZ setup
  enable_zone_redundant = true                             # Enable AZ redundancy within region (matches AWS cross-AZ)
  enable_multi_region   = var.cosmosdb_enable_multi_region # Keep false to match AWS single-region setup
  secondary_region      = var.cosmosdb_secondary_region    # Only used if multi_region is enabled

  # Network configuration - equivalent to AWS DocumentDB subnet placement
  subnet_ids = [
    module.vnet.private_subnet_ids[1], # db_main subnet access
    module.vnet.private_subnet_ids[2]  # db_alt subnet access
  ]
  enable_virtual_network_filter = true  # Equivalent to AWS VPC placement
  enable_public_network_access  = false # VPC-only access like AWS DocumentDB

  # Backup configuration - matches AWS DocumentDB backup settings
  backup_retention_hours = var.cosmosdb_backup_retention_hours # 7 days retention

  # Network Security Configuration - equivalent to AWS DocumentDB security group
  ingress_cidr_block = var.app_address_space # Allow access from app subnet (matches AWS pattern)

  # Tags for resource management (equivalent to AWS tags)
  tags = {
    Environment  = var.environment
    MigratedFrom = "AWS-DocumentDB"
  }
}
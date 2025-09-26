# Creates Azure VM with Node.js event-scheduler application for medical alert processing

module "event_scheduler_vm" {
  source = "../../../modules/event-scheduler"

  vm_name             = "${local.resource_name_prefix}-event-scheduler"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  vm_size             = var.event_scheduler_vm_size
  ssh_public_key      = var.ssh_public_key

  # Network configuration - equivalent to AWS VPC settings
  vnet_id             = module.vnet.vnet_id
  subnet_id           = module.vnet.private_subnet_ids[0] # Use the correct output
  allowed_cidr_blocks = ["10.13.0.32/28"]                 # App subnet CIDR - equivalent to AWS ingress_rules

  event_scheduler = {
    port = var.event_scheduler_port
  }

  # Backend API configuration - uses real Application Gateway endpoint
  backend_api = {
    endpoint = module.backend_lb.endpoint  # Real Application Gateway endpoint
    port     = 443                        # HTTPS port
  }

  # Database configuration - equivalent to AWS DocumentDB
  cosmosdb = {
    username     = var.cosmosdb_master_user_username
    password     = var.cosmosdb_master_user_password
    endpoint     = module.cosmosdb.cosmosdb_account_endpoint
    port         = "27017" # Standard MongoDB port for Cosmos DB
    account_name = module.cosmosdb.cosmosdb_account_name
  }

  # Inter-service authentication - same as AWS
  inter_server_auth_key = var.inter_server_auth_key

  # Storage account for application artifacts - equivalent to AWS S3 artifact bucket
  storage_account_name = azurerm_storage_account.artifacts_storage.name
  storage_account_key  = azurerm_storage_account.artifacts_storage.primary_access_key

  # VM storage configuration - equivalent to AWS root_block_device
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = var.event_scheduler_os_disk_type
    disk_size_gb         = var.event_scheduler_os_disk_size
  }

  tags = {
    Environment  = var.environment
    Service      = "EventScheduler"
    Purpose      = "MedicalAlerts"
    MigratedFrom = "AWS-EC2-EventScheduler"
  }
}
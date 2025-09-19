# Azure Event-Scheduler - equivalent to AWS event-scheduler EC2
# Creates Azure VM with Node.js event-scheduler application for medical alert processing
module "event_scheduler_vm" {
  source = "../../../modules/common/event-scheduler"

  # Basic VM configuration - equivalent to AWS instance settings
  vm_name             = "${local.resource_name_prefix}-event-scheduler"
  resource_group_name = module.resource_group.resource_group_name
  location            = var.location
  vm_size             = var.event_scheduler_vm_size # Equivalent to AWS instance_type
  ssh_public_key      = var.ssh_public_key          # Equivalent to AWS authorization_key

  # Network configuration - equivalent to AWS VPC settings
  vnet_id             = module.vnet.vnet_id
  subnet_id           = module.vnet.private_subnet_ids[0] # Use the correct output
  allowed_cidr_blocks = ["10.13.0.32/28"]                 # App subnet CIDR - equivalent to AWS ingress_rules

  # Event-scheduler service configuration - same as AWS
  event_scheduler = {
    port = var.event_scheduler_port
  }

  # Backend API configuration - equivalent to AWS backend_api
  # Note: backend_lb module needs to be created separately
  backend_api = {
    endpoint = "backend.${var.location_code}-${var.environment}.respiree.com" # Placeholder endpoint
    port     = 443                                                            # HTTPS port
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
  # Note: You'll need to create a storage account for artifacts and upload event-scheduler.zip
  storage_account_name = var.artifacts_storage_account_name
  storage_account_key  = var.artifacts_storage_account_key

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

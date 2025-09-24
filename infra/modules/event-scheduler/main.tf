# Azure Event-Scheduler Module - equivalent to AWS event-scheduler
# Creates Azure VM with Node.js event-scheduler application for medical alert processing

# Local variables for naming and configuration - equivalent to AWS locals
locals {
  split_vm_name             = split("-", var.vm_name)
  vm_name_capitalized_parts = [for part in local.split_vm_name : "${upper(substr(part, 0, 1))}${substr(part, 1, length(part))}"]
  pascal_case_vm_name       = join("", local.vm_name_capitalized_parts)
}

# Environment configuration for event-scheduler application - equivalent to AWS templatefile
locals {
  event_scheduler_env = templatefile("${path.module}/templates/env/event-scheduler.env.tpl", {
    port = var.event_scheduler.port,
    # Azure Cosmos DB connection string - equivalent to AWS DocumentDB
    mongo_uri        = "mongodb://${var.cosmosdb.username}:${var.cosmosdb.password}@${var.cosmosdb.endpoint}:${var.cosmosdb.port}/respiree?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@${var.cosmosdb.account_name}@",
    backend_auth_key = var.inter_server_auth_key
    backend_api_url  = "https://${var.backend_api.endpoint}:${var.backend_api.port}/api"
  })

  # VM initialization script - equivalent to AWS user_data
  init_script = templatefile("${path.module}/templates/setup/init.sh.tpl", {
    event_scheduler_env  = local.event_scheduler_env
    ssh_public_key       = var.ssh_public_key
    storage_account_name = var.storage_account_name
    storage_account_key  = var.storage_account_key
  })
}

# Azure VM for event-scheduler - equivalent to AWS EC2 instance
# Uses common VM module just like AWS uses common/ec2
module "this" {
  source = "../common/vm"

  # Basic VM configuration - equivalent to AWS instance settings
  instance_name       = var.vm_name
  resource_group_name = var.resource_group_name
  location           = var.location
  instance_type      = var.vm_size
  
  # Network configuration - equivalent to AWS VPC/subnet settings
  subnet_id = var.subnet_id
  
  # Security configuration - equivalent to AWS security groups
  ingress_rules = [
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = 22
      to_port     = 22
    },
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = var.event_scheduler.port
      to_port     = var.event_scheduler.port
    }
  ]

  # SSH configuration - equivalent to AWS key pair
  ssh_public_key = var.ssh_public_key

  # Storage configuration - equivalent to AWS root block device
  root_block_device = {
    caching     = var.os_disk.caching
    volume_type = var.os_disk.storage_account_type
    volume_size = var.os_disk.disk_size_gb
  }

  # User data script - equivalent to AWS user_data
  user_data = local.init_script

  tags = merge(
    var.tags,
    {
      Name         = var.vm_name
      Service      = "EventScheduler"
      Purpose      = "MedicalAlerts"
      MigratedFrom = "AWS-EC2-EventScheduler"
    }
  )
}

# Storage Account for application artifacts - equivalent to AWS S3 artifact bucket
# Note: This assumes you have a shared storage account for artifacts
# The actual nodejs file needs to be uploaded separately
# TODO: Create storage account separately and uncomment this
# data "azurerm_storage_account" "artifacts" {
#   name                = var.storage_account_name
#   resource_group_name = var.resource_group_name
# }

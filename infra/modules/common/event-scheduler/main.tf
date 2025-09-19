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

# Network Interface for event-scheduler VM - equivalent to AWS ENI
resource "azurerm_network_interface" "this" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vm_name}-nic"
    }
  )
}

# Network Security Group for event-scheduler - equivalent to AWS Security Group
resource "azurerm_network_security_group" "this" {
  name                = "${var.vm_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow event-scheduler port inbound - equivalent to AWS ingress rules
  security_rule {
    name                       = "Allow-EventScheduler-Inbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = tostring(var.event_scheduler.port)
    source_address_prefixes    = var.allowed_cidr_blocks
    destination_address_prefix = "*"
  }

  # Allow SSH inbound for management
  security_rule {
    name                       = "Allow-SSH-Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowed_cidr_blocks
    destination_address_prefix = "*"
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.vm_name}-nsg"
    }
  )
}

# Associate Network Security Group with Network Interface
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Azure VM for event-scheduler - equivalent to AWS EC2 instance
resource "azurerm_linux_virtual_machine" "this" {
  name                = var.vm_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size
  admin_username      = var.admin_username

  # Disable password authentication, use SSH keys only
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  # SSH key configuration - equivalent to AWS key pair
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # OS disk configuration - equivalent to AWS root block device
  os_disk {
    name                 = "${var.vm_name}-osdisk"
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  # Use Ubuntu 20.04 LTS - equivalent to AWS Amazon Linux
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Custom data script - equivalent to AWS user_data
  custom_data = base64encode(local.init_script)

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

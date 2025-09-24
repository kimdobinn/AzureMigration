# Azure Common VM Module - equivalent to AWS common/ec2 module
# This module creates the basic VM infrastructure that can be reused by different services

# Network Interface for VM - equivalent to AWS ENI
resource "azurerm_network_interface" "this" {
  name                = "${var.instance_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

# Network Security Group for VM - equivalent to AWS Security Group
resource "azurerm_network_security_group" "this" {
  name                = "${var.instance_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Security Group Rules - equivalent to AWS security group rules
resource "azurerm_network_security_rule" "ingress_rules" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  name                        = "Allow-${each.key}-Inbound"
  priority                    = 1000 + each.key
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "${each.value.from_port}-${each.value.to_port}"
  source_address_prefixes     = each.value.cidr_blocks
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Associate Network Security Group with Network Interface
resource "azurerm_network_interface_security_group_association" "this" {
  network_interface_id      = azurerm_network_interface.this.id
  network_security_group_id = azurerm_network_security_group.this.id
}

# Azure Linux VM - equivalent to AWS EC2 instance
resource "azurerm_linux_virtual_machine" "this" {
  name                = var.instance_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.instance_type
  admin_username      = "azureuser"

  # Disable password authentication, use SSH keys only
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.this.id,
  ]

  # SSH key configuration - equivalent to AWS key pair
  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  # OS disk configuration - equivalent to AWS root block device
  os_disk {
    name                 = "${var.instance_name}-osdisk"
    caching              = var.root_block_device.caching
    storage_account_type = var.root_block_device.volume_type
    disk_size_gb         = var.root_block_device.volume_size
  }

  # Use Ubuntu 20.04 LTS - equivalent to AWS Amazon Linux
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  # Custom data script - equivalent to AWS user_data
  custom_data = var.user_data != null ? base64encode(var.user_data) : null

  # Managed Identity configuration - equivalent to AWS instance profile
  dynamic "identity" {
    for_each = var.identity_ids != null ? [1] : []
    content {
      type         = "UserAssigned"
      identity_ids = var.identity_ids
    }
  }

  tags = var.tags
}
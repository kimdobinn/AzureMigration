#Reources: VM, NIC, NSG

resource "azurerm_linux_virtual_machine" "this" {
  name                = var.instance_name
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.instance_type
  admin_username      = "azureuser"  # Default admin login
  network_interface_ids = [
    azurerm_network_interface.this.id
  ]
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    name                 = "${var.instance_name}-osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.root_block_device.volume_type
    disk_size_gb         = var.root_block_device.volume_size
  }

  source_image_reference {
    publisher = "Canonical" 
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  tags = {
    Name = var.instance_name
  }
}

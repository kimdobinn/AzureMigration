# Azure Backend VM Instance - equivalent to AWS EC2 instance
# Creates the main backend VM using the common VM module

module "this" {
  source = "../common/vm"

  # Basic VM configuration
  instance_name       = var.instance_name
  resource_group_name = var.resource_group_name
  location            = var.location
  instance_type       = var.instance_type

  # Network configuration
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
      from_port   = var.backend_api.port
      to_port     = var.backend_api.port
    },
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = var.mqtt_service.port
      to_port     = var.mqtt_service.port
    },
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = var.stomp_service.port
      to_port     = var.stomp_service.port
    },
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = 61613 # ActiveMQ STOMP port
      to_port     = 61613
    },
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = 1883 # ActiveMQ MQTT port
      to_port     = 1883
    },
    {
      cidr_blocks = var.allowed_cidr_blocks
      from_port   = 8161 # ActiveMQ Web Console
      to_port     = 8161
    }
  ]

  # SSH configuration
  ssh_public_key = var.ssh_public_key

  # Storage configuration
  root_block_device = var.root_block_device

  # Managed Identity assignment (equivalent to AWS instance profile)
  identity_ids = [azurerm_user_assigned_identity.this.id]

  # VM initialization script (equivalent to AWS user_data)
  user_data = "${local.download_exec_init_script}\n${var.user_data}"

  # Tags
  tags = var.tags

  # Ensure initialization scripts are uploaded before VM creation
  depends_on = [
    azurerm_storage_blob.init_script_blob,
    azurerm_storage_blob.init_db_script_blob
  ]
}

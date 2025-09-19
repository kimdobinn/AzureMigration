module "vnet" {
  source = "../../../modules/common/vnet"
  #Azure location = AWS region
  location = var.location

  resource_name_prefix = local.resource_name_prefix
  #Azure address_space = AWS CIDR block
  vnet_address_space = var.vnet_address_space

  resource_group_name = module.resource_group.resource_group_name  # Use dynamic resource group

  public_subnets = [
    {
      name             = "web"
      address_prefix   = var.web_address_space_1
      use_alternate_az = false # availability zone assignment
    },
    {
      name             = "web-alt"
      address_prefix   = var.web_address_space_2
      use_alternate_az = true # alternate AZ for high availability
    }
  ]

  private_subnets = [
    {
      name             = "app"
      address_prefix   = var.app_address_space
      use_alternate_az = false # App tier in primary AZ
    },
    {
      name             = "db_main"
      address_prefix   = var.db_address_space_1
      use_alternate_az = false # Primary database subnet
    },
    {
      name             = "db_alt"
      address_prefix   = var.db_address_space_2
      use_alternate_az = true # Secondary database subnet for HA
    }
  ]


}

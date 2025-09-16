# KIRO EDIT: Updated variables to match AWS VPC module structure more closely

# VNet - Azure equivalent of AWS VPC
variable "location" {
  description = "Azure region to deploy VNet (equivalent to AWS region)."
  type        = string
}

variable "resource_name_prefix" {
  description = "A text prefix using standard dashed case to name VNet resources (matches AWS naming pattern)."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for VNet (equivalent to AWS VPC CIDR block)."
  type        = list(string)
}

variable "resource_group_name" {
  description = "Azure Resource Group name (no AWS equivalent - Azure-specific requirement)."
  type        = string
}

# Subnets - Azure equivalent of AWS subnets with availability zone support
variable "public_subnets" {
  description = "List of public subnets (equivalent to AWS public subnets). First subnet will host NAT Gateway."
  type = list(object({
    name                = string
    address_prefix      = string
    use_alternate_az    = bool  # KIRO EDIT: Added to match AWS availability zone logic
  }))
}

variable "private_subnets" {
  description = "List of private subnets (equivalent to AWS private subnets)."
  type = list(object({
    name                = string
    address_prefix      = string
    use_alternate_az    = bool  # KIRO EDIT: Added to match AWS availability zone logic
  }))
}

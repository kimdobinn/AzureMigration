# Azure Common VM Module Variables - equivalent to AWS common/ec2 variables

# Instance Configuration
variable "instance_name" {
  description = "Name of the virtual machine. Equivalent to AWS instance name."
  type        = string
}

variable "location" {
  description = "Azure region to deploy the VM in. Equivalent to AWS region."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to deploy resources into. No AWS equivalent."
  type        = string
}

variable "instance_type" {
  description = "The size of the VM. Equivalent to AWS instance_type."
  type        = string
}

# Network Configuration
variable "subnet_id" {
  description = "The subnet ID where the VM's NIC will be placed. Equivalent to AWS subnet_id."
  type        = string
}

variable "ingress_rules" {
  description = "List of ingress rules for the security group. Equivalent to AWS ingress_rules."
  type = list(object({
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
  }))
  default = []
}

# SSH Configuration
variable "ssh_public_key" {
  description = "SSH public key for VM access. Equivalent to AWS key pair."
  type        = string
}

# Storage Configuration
variable "root_block_device" {
  description = "Root disk configuration. Equivalent to AWS root_block_device."
  type = object({
    caching     = optional(string, "ReadWrite")
    volume_type = optional(string, "Premium_LRS")
    volume_size = optional(number, 30)
  })
  default = {
    caching     = "ReadWrite"
    volume_type = "Premium_LRS"
    volume_size = 30
  }
}

# User Data
variable "user_data" {
  description = "User data script to run on VM startup. Equivalent to AWS user_data."
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to VM resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}

# Managed Identity Configuration
variable "identity_ids" {
  description = "List of User Assigned Managed Identity IDs to assign to the VM. Equivalent to AWS instance profile."
  type        = list(string)
  default     = null
}
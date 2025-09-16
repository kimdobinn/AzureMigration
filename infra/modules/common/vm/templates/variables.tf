variable "instance_name" {
  description = "Name of the virtual machine."
  type        = string
}

variable "location" {
  description = "Azure region to deploy the VM in (e.g., eastus)."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the existing resource group to deploy resources into."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the VM's NIC will be placed."
  type        = string
}

variable "instance_type" {
  description = "The size of the VM (e.g., Standard_B1s)."
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key file used for logging into the VM."
  type        = string
}

variable "root_block_device" {
  description = "Root disk configuration."
  type = object({
    volume_size = number
    volume_type = string
  })
}

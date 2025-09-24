# Azure Event-Scheduler Module Variables - equivalent to AWS event-scheduler variables

# VM Configuration (equivalent to AWS Instance settings)
variable "vm_name" {
  description = "Name of the Azure VM for event-scheduler. Equivalent to AWS instance_name."
  type        = string
}

variable "resource_group_name" {
  description = "Azure Resource Group name. No AWS equivalent - Azure-specific requirement."
  type        = string
}

variable "location" {
  description = "Azure region for the VM. Equivalent to AWS region."
  type        = string
}

variable "vm_size" {
  description = "Azure VM size e.g. Standard_B1s. Equivalent to AWS instance_type."
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM. Equivalent to AWS ec2-user."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access. Equivalent to AWS authorization_key."
  type        = string
}

# Network Configuration (equivalent to AWS VPC settings)
variable "vnet_id" {
  description = "ID of VNet which the VM will be created in. Equivalent to AWS vpc_id."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet which the VM will be created in. Equivalent to AWS subnet_id."
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "List of CIDR blocks that can access the event-scheduler port. Equivalent to AWS ingress_rules."
  type        = list(string)
}

# Storage Configuration (equivalent to AWS root block device)
variable "os_disk" {
  description = "Object containing settings for VM's OS disk. Equivalent to AWS root_block_device."
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = optional(number, 30)
  })
  default = {}
}

# Application Configuration (equivalent to AWS user_data)
variable "custom_data_script" {
  description = "Additional scripts that will be executed on top of the default configuration. Equivalent to AWS user_data."
  type        = string
  default     = ""
}

# Event-Scheduler Service Configuration (same as AWS)
variable "event_scheduler" {
  description = "Object containing information for event-scheduler service. Same as AWS version."
  type = object({
    port = number
  })
}

variable "backend_api" {
  description = "Object containing information for backend-api service. Same as AWS version."
  type = object({
    endpoint = string
    port     = number
  })
}

# Database Configuration (equivalent to AWS DocumentDB)
variable "cosmosdb" {
  description = "Object containing information on the provisioned Cosmos DB database. Equivalent to AWS docdb."
  type = object({
    username     = string
    password     = string
    endpoint     = string
    port         = string
    account_name = string
  })
}

variable "inter_server_auth_key" {
  description = "API key used by event-scheduler and backend-api to communicate with each other. Same as AWS."
  type        = string
  sensitive   = true
}

# Storage Account for Application Artifacts (equivalent to AWS S3 artifact bucket)
variable "storage_account_name" {
  description = "Name of storage account containing application artifacts. Equivalent to AWS S3 artifact bucket."
  type        = string
}

variable "storage_account_key" {
  description = "Access key for storage account. Equivalent to AWS S3 access credentials."
  type        = string
  sensitive   = true
}

# Tags
variable "tags" {
  description = "Tags to apply to event-scheduler resources. Equivalent to AWS tags."
  type        = map(string)
  default     = {}
}
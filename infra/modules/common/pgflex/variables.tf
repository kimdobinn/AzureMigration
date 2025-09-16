#PostgreSQL Flexible Server Variables
variable "postgresql_flexible_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  type        = string
}
variable "resource_group_name" {
  description = "The name of the resource group where the PostgreSQL Flexible Server will be created."
  type        = string  
}
variable "location" {
  description = "The Azure region where the PostgreSQL Flexible Server will be deployed."
  type        = string
}
variable "postgresql_version" {
  description = "The version of PostgreSQL to use for the Flexible Server."
  type        = string
  default     = "15.10" 
}
variable "delegated_subnet_id" {
  description = "The ID of the delegated subnet for the PostgreSQL Flexible Server."
  type        = string
}
variable "private_dns_zone_id" {
  description = "The ID of the private DNS zone for the PostgreSQL Flexible Server."
  type        = string
  default     = null
}
variable "admin_username" {
  description = "The administrator username for the PostgreSQL Flexible Server."
  type        = string
  default     = "psqladmin"
}
variable "admin_password" {
  description = "The administrator password for the PostgreSQL Flexible Server."
  type        = string
  sensitive   = true  
}
variable "zone" {
  description = "The availability zone for the PostgreSQL Flexible Server."
  type        = string
}

variable "database_name" {
  description = "The name of the PostgreSQL database to create."
  type        = string
}

variable "port" {
  description = "Port number to access the database."
  type        = number
}

variable "vnet_name" {
  description = "The name of the virtual network to create."
  type        = string  
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

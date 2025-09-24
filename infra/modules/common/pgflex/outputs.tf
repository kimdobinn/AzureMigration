output "postgresql_server_id" {
  description = "The ID of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster ARN."
  value       = azurerm_postgresql_flexible_server.this.id
}

output "postgresql_server_name" {
  description = "The name of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster identifier."
  value       = azurerm_postgresql_flexible_server.this.name
}

output "postgresql_server_fqdn" {
  description = "The FQDN of the PostgreSQL Flexible Server. Equivalent to AWS RDS cluster endpoint."
  value       = azurerm_postgresql_flexible_server.this.fqdn
}

output "postgresql_server_version" {
  description = "The PostgreSQL version of the server."
  value       = azurerm_postgresql_flexible_server.this.version
}

output "postgresql_administrator_login" {
  description = "The administrator login for the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.this.administrator_login
}

output "postgresql_connection_string" {
  description = "Connection string for the PostgreSQL server (without password)."
  value       = "postgresql://${azurerm_postgresql_flexible_server.this.administrator_login}@${azurerm_postgresql_flexible_server.this.fqdn}:5432/"
}

output "postgresql_sku_name" {
  description = "The SKU name of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.this.sku_name
}

output "postgresql_storage_mb" {
  description = "The storage size in MB of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.this.storage_mb
}

output "postgresql_delegated_subnet_id" {
  description = "The subnet ID that the PostgreSQL server is delegated to."
  value       = azurerm_postgresql_flexible_server.this.delegated_subnet_id
}

output "postgresql_high_availability_enabled" {
  description = "Whether high availability is enabled for the PostgreSQL server."
  value       = length(azurerm_postgresql_flexible_server.this.high_availability) > 0
}

output "postgresql_high_availability_mode" {
  description = "The high availability mode of the PostgreSQL server (if enabled)."
  value       = length(azurerm_postgresql_flexible_server.this.high_availability) > 0 ? azurerm_postgresql_flexible_server.this.high_availability[0].mode : null
}

output "postgresql_standby_availability_zone" {
  description = "The availability zone of the standby server (if HA is enabled)."
  value       = length(azurerm_postgresql_flexible_server.this.high_availability) > 0 ? azurerm_postgresql_flexible_server.this.high_availability[0].standby_availability_zone : null
}

output "postgresql_database_name" {
  description = "The default database name for the PostgreSQL server."
  value       = "postgres"  # PostgreSQL Flexible Server always has a default 'postgres' database
}

# Note: NSG outputs removed as network security is now managed by the shared database NSG
# Both PostgreSQL and CosmosDB use the same NSG for unified database security management
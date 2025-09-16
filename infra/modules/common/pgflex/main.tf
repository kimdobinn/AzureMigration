resource "azurerm_postgresql_flexible_server" "this" {
  name                = var.postgresql_flexible_server_name
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = var.postgresql_version
  delegated_subnet_id = var.delegated_subnet_id
  private_dns_zone_id = var.private_dns_zone_id 
  public_network_access_enabled = false
  administrator_login = var.admin_username #master_username in AWS
  administrator_password = var.admin_password # master_password in AWS
  zone = var.zone

  storage_mb = 32768
  storage_tier = "P4"

  sku_name   = "GP_Standard_D2s_v4"
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "example" {
  name             = "example-fw"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "122.122.0.0"
  end_ip_address   = "122.122.0.0"
}

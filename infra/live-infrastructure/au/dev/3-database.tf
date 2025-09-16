resource "azurerm_postgresql_flexible_server" "this" {
  name                   = "${local.resource_name_prefix}-pgflex"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = var.postgresql_version
  administrator_login    = var.postgresql_flexible_server_admin_username
  administrator_password = var.postgresql_flexible_server_admin_password

  sku_name   = var.postgresql_flexible_server_sku_name #Can try other SKUs later.
  storage_mb = var.postgresql_flexible_server_storage_mb # choose from: [32768 65536 131072 262144 524288 1048576 2097152 4193280 4194304 8388608 16777216 33553408]
}

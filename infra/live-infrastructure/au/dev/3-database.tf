resource "azurem_postgresql_flexible_server" "this" {
  name = "${local.resource_name_prefix}-pgflex"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.postgresql_version
  administrator_login          = local.secret_value["pgflex_admin_username"] #need to figure this out
  administrator_login_password = local.secret_value["pgflex_admin_password"] #what this secret_value thing is

  sku_name   = "GP_Standard_D2s_v3" #Can try other SKUs later.
  storage_mb = 5120 # 5 GB, Initial value, will scale up as needed. Not sure how much to put this as.
}

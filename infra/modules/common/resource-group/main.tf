resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      Name        = var.resource_group_name
      Environment = var.environment
      Region      = var.location_code
      ManagedBy   = "Terraform"
    }
  )
}
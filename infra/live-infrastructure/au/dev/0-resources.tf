locals {
  resource_name_prefix = "${var.location_code}-${var.environment}"

  split_resource_name_prefix             = split("-", local.resource_name_prefix)
  resource_name_prefix_capitalized_parts = [for part in local.split_resource_name_prefix : "${upper(substr(part, 0, 1))}${substr(part, 1, length(part))}"]
  pascal_case_resource_name_prefix       = join("", local.resource_name_prefix_capitalized_parts)
}

# Resource group name generation: au-dev -> rg-au-dev
locals {
  resource_group_name = "rg-${local.resource_name_prefix}"  # Creates: rg-au-dev, rg-au-prod, etc.
}

# Create the resource group for this environment - direct resource like AWS S3 buckets
# This automatically creates rg-au-dev, rg-au-prod, rg-us-dev, etc. based on location_code and environment
resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location

  tags = {
    Project     = "RespireeAzure"
    ManagedBy   = "Terraform"
    Environment = var.environment
    Region      = var.location_code
    Name        = local.resource_group_name
  }
}
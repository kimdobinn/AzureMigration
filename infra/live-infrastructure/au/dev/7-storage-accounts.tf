# Azure Storage Accounts - equivalent to AWS S3 buckets
# Using multiple storage accounts to match AWS S3 bucket isolation and security model

locals {
  app_storage_name       = "${replace(local.resource_name_prefix, "-", "")}appstorage"
  thumbnail_storage_name = "${replace(local.resource_name_prefix, "-", "")}thumbnailstorage"
  artifacts_storage_name = "${replace(local.resource_name_prefix, "-", "")}artifactsstorage"
}

# App Storage Account - equivalent to AWS app-bucket
resource "azurerm_storage_account" "app_storage" {
  name                     = local.app_storage_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Private access (equivalent to AWS S3 private bucket)
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  tags = {
    Name         = local.app_storage_name
    Environment  = var.environment
    MigratedFrom = "AWS-S3-AppBucket"
  }
}

# App storage container - equivalent to S3 bucket content
resource "azurerm_storage_container" "app_container" {
  name                  = "app-data"
  storage_account_id    = azurerm_storage_account.app_storage.id
  container_access_type = "private"
}

# Thumbnail Storage Account - equivalent to AWS thumbnail-bucket
resource "azurerm_storage_account" "thumbnail_storage" {
  name                     = local.thumbnail_storage_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Public access enabled for thumbnails (equivalent to AWS S3 public bucket)
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = true

  tags = {
    Name         = local.thumbnail_storage_name
    Environment  = var.environment
    MigratedFrom = "AWS-S3-ThumbnailBucket"
  }
}

# Thumbnail storage container with public read access - equivalent to S3 public policy
resource "azurerm_storage_container" "thumbnail_container" {
  name                  = "thumbnails"
  storage_account_id    = azurerm_storage_account.thumbnail_storage.id
  container_access_type = "blob" # Public read access for blobs
}

# Artifacts Storage Account - equivalent to AWS respiree-artifact-bucket
resource "azurerm_storage_account" "artifacts_storage" {
  name                     = local.artifacts_storage_name
  resource_group_name      = azurerm_resource_group.this.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Private access (equivalent to AWS S3 private bucket)
  public_network_access_enabled   = false
  allow_nested_items_to_be_public = false

  tags = {
    Name         = local.artifacts_storage_name
    Environment  = var.environment
    MigratedFrom = "AWS-S3-ArtifactBucket"
  }
}

# Artifacts storage container - equivalent to S3 bucket content
resource "azurerm_storage_container" "artifacts_container" {
  name                  = "artifacts"
  storage_account_id    = azurerm_storage_account.artifacts_storage.id
  container_access_type = "private"
}

# Storage Account Access Keys - equivalent to AWS IAM user access keys
# These provide programmatic access to storage accounts for applications

# App storage access (equivalent to AWS IAM policy for app bucket)
data "azurerm_storage_account_blob_container_sas" "app_sas" {
  connection_string = azurerm_storage_account.app_storage.primary_connection_string
  container_name    = azurerm_storage_container.app_container.name
  https_only        = true

  start  = "2024-01-01T00:00:00Z"
  expiry = "2025-12-31T23:59:59Z"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

# Thumbnail storage access (equivalent to AWS IAM policy for thumbnail bucket)
data "azurerm_storage_account_blob_container_sas" "thumbnail_sas" {
  connection_string = azurerm_storage_account.thumbnail_storage.primary_connection_string
  container_name    = azurerm_storage_container.thumbnail_container.name
  https_only        = true

  start  = "2024-01-01T00:00:00Z"
  expiry = "2025-12-31T23:59:59Z"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

# Artifacts storage access (equivalent to AWS IAM policy for artifact bucket)
data "azurerm_storage_account_blob_container_sas" "artifacts_sas" {
  connection_string = azurerm_storage_account.artifacts_storage.primary_connection_string
  container_name    = azurerm_storage_container.artifacts_container.name
  https_only        = true

  start  = "2024-01-01T00:00:00Z"
  expiry = "2025-12-31T23:59:59Z"

  permissions {
    read   = true
    add    = true
    create = true
    write  = true
    delete = true
    list   = true
  }
}

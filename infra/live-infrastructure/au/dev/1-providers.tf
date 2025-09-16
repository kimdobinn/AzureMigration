provider "azurerm" {
  features {}
  subscription_id = "a987c18a-17c7-41ab-8a25-7212c2a1e09f"
}

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.36.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "RespireeAzureResourceGroup"
    storage_account_name = "respireeazstorageaccount"
    container_name       = "tfstate"                   # 👈 Must exist already
    key                  = "dev/terraform.tfstate"     # 👈 Equivalent to S3 key
  }
}
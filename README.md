# Azure Terraform Infra Setup (from AWS Migration)

## Summary
Rebuilding AWS backend infrastructure from scratch using Azure Terraform resources.

## Modules
- Virtual Network (VNet)
- Subnets & NSGs
- Virtual Machines (Linux)
- PostgreSQL Flexible Server
- Azure Storage Account
- Private DNS + Delegated Subnets
- Key Vault + Secrets Management

## Highlights
- Fully modular structure using Terraform
- Follows best practices for resource grouping and reusability
- Handles production/staging environment configuration with `terraform.tfvars`
- Uses separate state files for each environment
- Rewritten from scratch based on AWS → Azure service mapping
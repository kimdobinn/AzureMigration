# Azure VNet Module - AWS VPC Equivalent

## Overview
This module creates an Azure Virtual Network (VNet) that mirrors the functionality of the AWS VPC module. It provides the same multi-tier architecture with public and private subnets, NAT Gateway for outbound internet access, and private DNS zones.

## AWS to Azure Mapping

| AWS Resource | Azure Resource | File | Notes |
|--------------|----------------|------|-------|
| VPC | Virtual Network | `1-vnet.tf` | Network isolation container |
| Public Subnets | Public Subnets | `2-subnet.tf` | Internet-accessible subnets |
| Private Subnets | Private Subnets | `2-subnet.tf` | Internal subnets with NAT Gateway access |
| Internet Gateway | Implicit | N/A | Azure provides automatic internet access |
| NAT Gateway | NAT Gateway | `3-gateways.tf` | Outbound internet for private subnets |
| Elastic IP | Public IP | `3-gateways.tf` | Static IP for NAT Gateway |
| Route Tables | Route Tables | `4-routes.tf` | Traffic routing control |
| Route53 Private Zone | Private DNS Zone | Database Module | Internal DNS resolution |

## Architecture
```
Internet
    |
[Azure Internet Gateway - Implicit]
    |
[Public Subnets] --> [NAT Gateway] --> [Private Subnets]
    |                                        |
[Web Tier]                              [App & DB Tiers]
```

## Key Differences from AWS
1. **Internet Gateway**: Azure provides implicit internet access for public subnets
2. **NAT Gateway**: Requires explicit subnet association in addition to route tables
3. **Availability Zones**: Azure uses different AZ naming (1,2,3 vs a,b,c)
4. **DNS**: Private DNS zones require explicit VNet linking
5. **Resource Groups**: Azure-specific requirement for resource organization

## Usage
See `live-infrastructure/au/dev/2-network.tf` for example usage that matches the AWS pattern.
# Azure Backend Module

This module creates the Azure backend infrastructure equivalent to AWS EC2-based backend services. It provides a complete backend VM with Node.js API, ActiveMQ message broker, MQTT/STOMP services, and database connectivity.

## Overview

The module creates:
- **Azure Virtual Machine** for backend services (equivalent to AWS EC2)
- **Managed Identity** for Azure resource authentication (equivalent to AWS IAM role)
- **Network Security Rules** for service access (equivalent to AWS security groups)
- **ActiveMQ Message Broker** installed on VM (same as AWS)
- **Multiple Backend Services** running via PM2 process manager

## Architecture

```
Internet → Application Gateway → Backend VM
                                    ├── Backend API (Node.js) :3000
                                    ├── MQTT Service (Python) :5000
                                    ├── STOMP Service (Python) :6000
                                    ├── ActiveMQ Broker :61613/:1883
                                    └── Dashboard (React) → Storage
```

## File Structure (AWS-Compatible)

```
modules/backend/
├── 0-resources.tf          # Environment templates and storage blobs
├── 1-instance-user.tf      # Managed identity and role assignments
├── 2-instance.tf           # VM creation using common/vm module
├── variables.tf            # Input variables (AWS-compatible structure)
├── outputs.tf              # Module outputs
├── README.md               # This file
└── templates/
    ├── env/
    │   ├── backend.env.tpl      # Backend API environment
    │   ├── dashboard.env.tpl    # React dashboard environment
    │   ├── mqtt-service.env.tpl # MQTT service environment
    │   └── stomp-service.env.tpl# STOMP service environment
    └── setup/
        ├── init.sh.tpl              # Main initialization script
        ├── download_exec_init.sh.tpl# Script downloader
        └── init_db.sql.tpl          # Database initialization
```

## Services Deployed

### 1. Backend API (Node.js)
- **Port**: 3000
- **Framework**: NestJS/Express
- **Database**: PostgreSQL connection
- **Features**: REST API, JWT authentication, file uploads

### 2. MQTT Service (Python)
- **Port**: 5000
- **Framework**: FastAPI + Uvicorn
- **Purpose**: MQTT message processing and gateway communication
- **ActiveMQ Integration**: Connects to local ActiveMQ broker

### 3. STOMP Service (Python)
- **Port**: 6000
- **Framework**: FastAPI + Uvicorn
- **Purpose**: STOMP message processing and real-time communication
- **ActiveMQ Integration**: Subscribes to queues and topics

### 4. ActiveMQ Message Broker
- **STOMP Port**: 61613
- **MQTT Port**: 1883
- **Web Console**: 8161
- **Version**: 5.18.3
- **Configuration**: Custom XML with optimized settings

### 5. Frontend Dashboard
- **Framework**: React
- **Deployment**: Built and uploaded to Azure Storage static website
- **CDN**: Served via Azure CDN for global distribution

## Usage

```hcl
module "backend_vm" {
  source = "../../../modules/backend"

  # Basic configuration
  instance_name       = "respiree-au-dev-backend"
  resource_group_name = "rg-au-dev"
  location            = "australiaeast"
  instance_type       = "Standard_B2s"

  # Network configuration
  subnet_id           = module.vnet.private_subnet_ids[0]
  allowed_cidr_blocks = ["10.13.0.0/24"]
  ssh_public_key      = var.ssh_public_key

  # Storage configuration
  storage_account_name = "respireeartifacts"
  storage_account_key  = "storage_key"
  artifact_folder      = "artifacts"

  # Database configuration
  rds_db = {
    host     = "respiree-pgflex.postgres.database.azure.com"
    port     = "5432"
    name     = "postgres"
    username = "psqladmin"
    password = "password"
  }

  # Notification configuration
  notification_config = module.notification.notification_config

  # ... other configurations
}
```

## Key Features

### AWS Compatibility
- **File Structure**: Matches AWS backend module exactly (0-resources.tf, 1-instance-user.tf, 2-instance.tf)
- **Template Structure**: Same environment and setup templates as AWS
- **Variable Structure**: Compatible with existing AWS configurations
- **Service Architecture**: Identical service deployment pattern

### Azure Adaptations
- **Managed Identity**: Replaces AWS IAM roles for secure resource access
- **Azure Storage**: Replaces AWS S3 for artifact storage and script deployment
- **Azure CLI**: Used instead of AWS CLI for resource management
- **Ubuntu**: Uses Ubuntu instead of Amazon Linux (apt-get vs yum)

### Security Features
- **Managed Identity**: No stored credentials, uses Azure AD authentication
- **Network Security**: Configurable ingress rules for service access
- **Role-based Access**: Least-privilege access to required Azure resources
- **SSH Key Authentication**: Secure VM access

### Deployment Process
1. **Template Generation**: Creates environment files for all services
2. **Script Upload**: Uploads initialization scripts to Azure Storage
3. **VM Creation**: Creates VM with managed identity and network configuration
4. **Service Installation**: Downloads and installs all required software
5. **Application Deployment**: Downloads, builds, and starts all services
6. **Database Initialization**: Runs SQL scripts to set up database schema

## Environment Variables

The module generates AWS-compatible environment variables for seamless application migration:

```bash
# Database (PostgreSQL)
DB_HOST=respiree-pgflex.postgres.database.azure.com
DB_PORT=5432
DB_NAME=postgres

# Storage (Azure Storage with AWS-compatible variables)
AWS_S3_ACCESS_KEY_ID=<azure_client_id>
AWS_S3_SECRET_ACCESS_KEY=<azure_client_secret>
AWS_PUBLIC_BUCKET_NAME=<storage_account_name>

# Notifications (Azure Communication Services with AWS-compatible variables)
AWS_SNS_ACCESS_KEY_ID=<azure_client_id>
AWS_SES_ACCESS_KEY_ID=<azure_client_id>
```

## Monitoring and Logging

- **PM2 Process Manager**: Manages all Node.js and Python services
- **Log Rotation**: Automatic log rotation via pm2-logrotate
- **Service Monitoring**: PM2 provides process monitoring and auto-restart
- **ActiveMQ Console**: Web-based monitoring at port 8161

## Troubleshooting

### Common Issues
1. **Service startup failures** - Check PM2 logs: `pm2 logs`
2. **Database connection errors** - Verify PostgreSQL connectivity and credentials
3. **ActiveMQ connection issues** - Check ActiveMQ service status: `systemctl status activemq`
4. **Storage access errors** - Verify managed identity permissions

### Useful Commands
```bash
# Check service status
pm2 status

# View service logs
pm2 logs backend-api
pm2 logs mqtt-service
pm2 logs stomp-service

# Restart services
pm2 restart all

# Check ActiveMQ status
systemctl status activemq
```

## Migration Notes

This module maintains full compatibility with the AWS backend module while leveraging Azure-native services:

- **Same file structure** as AWS (0-resources.tf, 1-instance-user.tf, 2-instance.tf)
- **Same template structure** for environment and setup files
- **Same service architecture** with identical ports and configurations
- **AWS-compatible environment variables** for seamless application migration

The application code requires no changes when migrating from AWS to Azure using this module.
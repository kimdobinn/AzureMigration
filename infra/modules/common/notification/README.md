# Azure Notification Module

This module creates Azure notification infrastructure equivalent to AWS SNS + SES services. It provides email delivery capabilities and topic-based messaging for cloud logging and alerting.

## Overview

The module creates:
- **Azure Communication Services** for email delivery (equivalent to AWS SES)
- **Azure Service Bus** with topics for message distribution (equivalent to AWS SNS)
- **Service Principal** for programmatic access (equivalent to AWS IAM user with access keys)
- **Managed Identity** for Azure resource authentication

## Architecture

```
Application → Service Bus Topic → Email Notifications
           ↘ Communication Services → Direct Email Delivery
```

## Resources Created

### Communication Services (Email Delivery)
- `azurerm_communication_service` - Main communication service
- `azurerm_email_communication_service` - Email-specific service
- `azurerm_email_communication_service_domain` - Azure-managed email domain

### Service Bus (Topic Messaging)
- `azurerm_servicebus_namespace` - Service Bus namespace
- `azurerm_servicebus_topic` - Cloud logging topic
- `azurerm_servicebus_subscription` - Email notification subscription

### Authentication & Authorization
- `azuread_application` - Application registration
- `azuread_service_principal` - Service principal for authentication
- `azuread_application_password` - Client secret
- `azurerm_user_assigned_identity` - Managed identity
- Role assignments for proper permissions

## Usage

```hcl
module "notification" {
  source = "../../../modules/common/notification"

  location            = "australiaeast"
  resource_group_name = "rg-au-dev"
  resource_name_prefix = "respiree-au-dev"

  topic_name = "respiree-au-dev-cloud-log"
  subscription_email_addresses = [
    "admin@company.com",
    "devops@company.com"
  ]

  tags = {
    Environment = "dev"
    Service     = "Notification"
  }
}
```

## Application Integration

The module provides both Azure-native and AWS-compatible configuration:

### Azure Configuration
```bash
AZURE_CLIENT_ID=<client_id>
AZURE_CLIENT_SECRET=<client_secret>
AZURE_TENANT_ID=<tenant_id>
AZURE_COMMUNICATION_CONNECTION_STRING=<connection_string>
AZURE_SERVICEBUS_CONNECTION_STRING=<connection_string>
AZURE_TOPIC_NAME=<topic_name>
```

### AWS-Compatible Configuration
```bash
AWS_SNS_ACCESS_KEY_ID=<client_id>
AWS_SNS_SECRET_ACCESS_KEY=<client_secret>
AWS_SNS_REGION=<location>
AWS_SES_ACCESS_KEY_ID=<client_id>
AWS_SES_SECRET_ACCESS_KEY=<client_secret>
AWS_SES_REGION=<location>
```

## Important Notes

### Email Domain Verification
- Azure Communication Services uses Azure-managed domains by default
- For production use with custom domains, additional DNS configuration is required
- Email sending may be limited until domain verification is complete

### Service Bus Pricing
- Standard tier is required for topics and subscriptions
- Basic tier only supports queues
- Premium tier provides enhanced performance and features

### Authentication Methods
1. **Service Principal** - For application authentication (equivalent to AWS access keys)
2. **Managed Identity** - For Azure resource authentication (recommended for Azure VMs)

## Outputs

| Name | Description | Sensitive |
|------|-------------|-----------|
| `client_id` | Service principal client ID | No |
| `client_secret` | Service principal client secret | Yes |
| `tenant_id` | Azure AD tenant ID | No |
| `communication_service_name` | Communication service name | No |
| `servicebus_namespace_name` | Service Bus namespace name | No |
| `topic_name` | Service Bus topic name | No |
| `notification_config` | Complete configuration object | Yes |

## Migration from AWS

This module provides equivalent functionality to:
- **AWS SNS** → Azure Service Bus Topics
- **AWS SES** → Azure Communication Services
- **AWS IAM User** → Azure Service Principal + Managed Identity

The application code can use the AWS-compatible environment variables for seamless migration.

## Security Considerations

- Client secrets are marked as sensitive and should be stored securely
- Managed Identity is preferred over service principal for Azure resources
- Role assignments follow principle of least privilege
- Service Bus topics support access control and message encryption

## Troubleshooting

### Common Issues
1. **Email delivery failures** - Check domain verification status
2. **Authentication errors** - Verify client ID/secret and tenant ID
3. **Permission denied** - Check role assignments and scope
4. **Topic not found** - Ensure Service Bus namespace and topic are created

### Monitoring
- Use Azure Monitor for Service Bus metrics
- Enable diagnostic logs for Communication Services
- Monitor authentication failures in Azure AD logs
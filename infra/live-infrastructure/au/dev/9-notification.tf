# Azure Notification Infrastructure - equivalent to AWS SNS + SES
# Creates Communication Services for email delivery and Service Bus for topic-based messaging

module "notification" {
  source = "../../../modules/common/notification"

  # Basic configuration
  location             = var.location
  resource_group_name  = azurerm_resource_group.this.name
  resource_name_prefix = local.resource_name_prefix

  # Topic configuration (equivalent to AWS SNS topic)
  topic_name = "${local.resource_name_prefix}-cloud-log"

  # Email subscription configuration
  subscription_email_addresses = var.notification_subscription_email_addresses

  # Service Bus configuration
  servicebus_sku    = var.notification_servicebus_sku
  topic_max_size_mb = var.notification_topic_max_size_mb
  message_ttl_days  = var.notification_message_ttl_days

  # Advanced configuration
  enable_duplicate_detection         = var.notification_enable_duplicate_detection
  duplicate_detection_window_minutes = var.notification_duplicate_detection_window_minutes

  # Tags
  tags = {
    Environment  = var.environment
    Service      = "Notification"
    MigratedFrom = "AWS-SNS-SES"
  }
}

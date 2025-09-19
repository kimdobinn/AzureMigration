# Note: Azure Service Bus vs AWS MQ Protocol Differences
# 
# AWS MQ (ActiveMQ) supported:
# - MQTT (port 8883) - for IoT devices
# - STOMP (port 61614) - for web applications  
# - OpenWire (port 61617) - for Java applications
#
# Azure Service Bus supports:
# - AMQP 1.0 (port 5671) - industry standard, more efficient than STOMP
# - HTTPS/REST (port 443) - for web applications and REST clients
# - .NET messaging APIs - for .NET applications
#
# Migration Notes:
# 1. MQTT clients → Use AMQP 1.0 or HTTPS REST API
# 2. STOMP clients → Use AMQP 1.0 or HTTPS REST API
# 3. Connection strings and authentication will need to be updated in applications (Connection strings → Update to Service Bus connection strings)
# 4. Authentication → Use Azure Service Bus shared access keys

module "servicebus" {
  source = "../../../modules/common/servicebus"

  namespace_name      = "${local.resource_name_prefix}-servicebus" # AWS MQ broker name
  location            = var.location                               # AWS region
  resource_group_name = module.resource_group.resource_group_name

  # AWS mq.t2.micro -> Azure Standard SKU (good for dev/test)
  # AWS mq.t3.small -> Azure Standard SKU (production ready)
  # AWS mq.m5.large+ -> Azure Premium SKU (high performance)
  sku                 = var.servicebus_sku                 # Standard for dev, Premium for prod
  capacity            = var.servicebus_capacity            # Only used for Premium SKU
  publicly_accessible = var.servicebus_publicly_accessible # AWS MQ publicly_accessible

  # Topic and Queue configuration = AWS MQ destinations
  # These replace the ActiveMQ topic and queue from your AWS setup
  gw_report_topic_name = var.mq_gw_report_topic_name # Same topic name as AWS
  gw_report_queue_name = var.mq_gw_report_queue_name # Same queue name as AWS

  # Message configuration - equivalent to ActiveMQ settings
  # Note: Partitioning is handled automatically by Azure Service Bus
  max_topic_size_mb   = var.servicebus_max_topic_size_mb   # Equivalent to AWS MQ storage limits
  max_queue_size_mb   = var.servicebus_max_queue_size_mb   # Equivalent to AWS MQ storage limits
  default_message_ttl = var.servicebus_default_message_ttl # Equivalent to ActiveMQ message expiration
  max_delivery_count  = var.servicebus_max_delivery_count  # Equivalent to ActiveMQ redelivery policy

  # Network configuration
  create_private_endpoint = var.servicebus_create_private_endpoint
  app_subnet_cidr         = var.app_address_space

  tags = {
    Environment  = var.environment
    MigratedFrom = "AWS-MQ-ActiveMQ"
    Protocol     = "AMQP" # Azure Service Bus uses AMQP instead of MQTT/STOMP
  }
}

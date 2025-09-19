resource "azurerm_servicebus_namespace" "this" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name

  # SKU configuration = AWS MQ instance_type
  # Basic = mq.t2.micro, 
  # Standard = mq.t3.small, 
  # Premium = mq.m5.large+
  sku      = var.sku
  capacity = var.sku == "Premium" ? var.capacity : null

  # Network configuration = AWS MQ publicly_accessible
  public_network_access_enabled = var.publicly_accessible

  # Note: Zone redundancy in Azure Service Bus is configured at the region level
  # and is automatically available for Premium SKU in supported regions
  # No explicit zone_redundant attribute is needed

  tags = merge(
    var.tags,
    {
      Name         = var.namespace_name
      Service      = "MessageBroker"
      MigratedFrom = "AWS-MQ-ActiveMQ"
    }
  )
}

# Service Bus Topic - equivalent to AWS MQ Topic (for pub/sub messaging)
# This replaces the ActiveMQ topic functionality
resource "azurerm_servicebus_topic" "report_topic" {
  name         = var.gw_report_topic_name
  namespace_id = azurerm_servicebus_namespace.this.id

  # Topic configuration - equivalent to ActiveMQ topic settings
  # Note: Partitioning in Azure Service Bus is handled automatically by the service
  # No explicit partitioning configuration is needed

  # Message retention and size limits
  max_size_in_megabytes = var.max_topic_size_mb
  default_message_ttl   = var.default_message_ttl

  # Note: Service Bus topics inherit tags from the parent namespace
  # Individual topics don't support direct tagging
}

# Service Bus Queue - equivalent to AWS MQ Queue (for point-to-point messaging)
# This replaces the ActiveMQ queue functionality
resource "azurerm_servicebus_queue" "report_queue" {
  name         = var.gw_report_queue_name
  namespace_id = azurerm_servicebus_namespace.this.id

  # Queue configuration - equivalent to ActiveMQ queue settings
  # Note: Partitioning in Azure Service Bus is handled automatically by the service
  # No explicit partitioning configuration is needed

  # Message retention and processing settings
  max_size_in_megabytes = var.max_queue_size_mb
  default_message_ttl   = var.default_message_ttl

  # Dead letter queue configuration (equivalent to ActiveMQ DLQ)
  dead_lettering_on_message_expiration = true
  max_delivery_count                   = var.max_delivery_count

  # Note: Service Bus queues inherit tags from the parent namespace
  # Individual queues don't support direct tagging
}

# Service Bus Subscription - equivalent to AWS MQ Topic Subscription
# This creates the topic-to-queue forwarding (like ActiveMQ compositeTopic)
resource "azurerm_servicebus_subscription" "topic_to_queue" {
  name     = "forward-to-queue"
  topic_id = azurerm_servicebus_topic.report_topic.id

  # Subscription configuration
  max_delivery_count = var.max_delivery_count

  # Auto-forward messages from topic to queue (equivalent to ActiveMQ compositeTopic)
  forward_to = azurerm_servicebus_queue.report_queue.name
}

# Network Security Group for Service Bus (if using private endpoints)
# Equivalent to AWS MQ security group
resource "azurerm_network_security_group" "this" {
  count               = var.create_private_endpoint ? 1 : 0
  name                = "${var.namespace_name}-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(
    var.tags,
    {
      Name         = "${var.namespace_name}-nsg"
      Service      = "MessageBroker-Security"
      MigratedFrom = "AWS-MQ-SecurityGroup"
    }
  )
}

# Security rules for AMQP, MQTT, and HTTPS (equivalent to AWS MQ ports)
resource "azurerm_network_security_rule" "amqp_ingress" {
  count                       = var.create_private_endpoint ? 1 : 0
  name                        = "Allow-AMQP-Ingress"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5671"
  source_address_prefix       = var.app_subnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[0].name
}

resource "azurerm_network_security_rule" "https_ingress" {
  count                       = var.create_private_endpoint ? 1 : 0
  name                        = "Allow-HTTPS-Ingress"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.app_subnet_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[0].name
}

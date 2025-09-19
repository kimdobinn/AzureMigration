# Service Bus Namespace Outputs (equivalent to AWS MQ broker outputs)
output "namespace_id" {
  description = "The ID of the Service Bus namespace. Equivalent to AWS MQ broker ID."
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "The name of the Service Bus namespace. Equivalent to AWS MQ broker name."
  value       = azurerm_servicebus_namespace.this.name
}

output "primary_connection_string" {
  description = "Primary connection string for the Service Bus namespace. Equivalent to AWS MQ connection URL."
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "secondary_connection_string" {
  description = "Secondary connection string for the Service Bus namespace. Backup connection."
  value       = azurerm_servicebus_namespace.this.default_secondary_connection_string
  sensitive   = true
}

# Endpoint Information (equivalent to AWS MQ endpoints)
output "endpoint" {
  description = "Service Bus namespace endpoint. Equivalent to AWS MQ broker endpoint."
  value       = "https://${azurerm_servicebus_namespace.this.name}.servicebus.windows.net/"
}

output "hostname" {
  description = "Service Bus namespace hostname. For application configuration."
  value       = "${azurerm_servicebus_namespace.this.name}.servicebus.windows.net"
}

# Topic and Queue Information
output "topic_id" {
  description = "The ID of the Service Bus topic. Equivalent to AWS MQ topic ARN."
  value       = azurerm_servicebus_topic.report_topic.id
}

output "topic_name" {
  description = "The name of the Service Bus topic."
  value       = azurerm_servicebus_topic.report_topic.name
}

output "queue_id" {
  description = "The ID of the Service Bus queue. Equivalent to AWS MQ queue ARN."
  value       = azurerm_servicebus_queue.report_queue.id
}

output "queue_name" {
  description = "The name of the Service Bus queue."
  value       = azurerm_servicebus_queue.report_queue.name
}

output "subscription_id" {
  description = "The ID of the Service Bus subscription (topic-to-queue forwarding)."
  value       = azurerm_servicebus_subscription.topic_to_queue.id
}

# Connection Information for Applications
output "connection_info" {
  description = "Connection information for applications. Equivalent to AWS MQ connection details."
  value = {
    namespace_name = azurerm_servicebus_namespace.this.name
    endpoint       = "https://${azurerm_servicebus_namespace.this.name}.servicebus.windows.net/"
    topic_name     = azurerm_servicebus_topic.report_topic.name
    queue_name     = azurerm_servicebus_queue.report_queue.name
    
    # Protocol information (Azure Service Bus uses AMQP, HTTPS, not MQTT/STOMP like ActiveMQ)
    protocols = {
      amqp  = "amqps://${azurerm_servicebus_namespace.this.name}.servicebus.windows.net:5671"
      https = "https://${azurerm_servicebus_namespace.this.name}.servicebus.windows.net/"
    }
  }
}
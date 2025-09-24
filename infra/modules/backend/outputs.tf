# Azure Backend Module Outputs - equivalent to AWS backend outputs

# VM Outputs
output "id" {
  description = "The ID of the backend VM. Equivalent to AWS instance ID."
  value       = module.this.id
}

output "name" {
  description = "The name of the backend VM. Equivalent to AWS instance name."
  value       = module.this.name
}

output "private_ip_address" {
  description = "The private IP address of the backend VM. Equivalent to AWS instance private IP."
  value       = module.this.private_ip_address
}

output "network_interface_id" {
  description = "The network interface ID of the backend VM. Used by Application Gateway."
  value       = module.this.network_interface_id
}

# Service Endpoints
output "backend_api_endpoint" {
  description = "Backend API endpoint. Same as AWS."
  value       = "${module.this.private_ip_address}:${var.backend_api.port}"
}

output "mqtt_service_endpoint" {
  description = "MQ service endpoint. Same as AWS."
  value       = "${module.this.private_ip_address}:${var.mqtt_service.port}"
}

output "stomp_service_endpoint" {
  description = "STOMP service endpoint. Same as AWS."
  value       = "${module.this.private_ip_address}:${var.stomp_service.port}"
}

# For compatibility with existing code
output "endpoint" {
  description = "Main backend endpoint (alias for backend_api_endpoint)."
  value       = module.this.private_ip_address
}

output "port" {
  description = "Main backend port."
  value       = var.backend_api.port
}
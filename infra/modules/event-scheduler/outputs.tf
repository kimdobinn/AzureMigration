# Azure Event-Scheduler Module Outputs - equivalent to AWS event-scheduler outputs

# Azure Event-Scheduler Module Outputs - equivalent to AWS event-scheduler outputs
# Now using common VM module outputs

# VM Outputs (equivalent to AWS EC2 outputs)
output "id" {
  description = "The ID of the event-scheduler VM. Equivalent to AWS instance ID."
  value       = module.this.id
}

output "name" {
  description = "The name of the event-scheduler VM. Equivalent to AWS instance name."
  value       = module.this.name
}

output "endpoint" {
  description = "The private IP endpoint of the event-scheduler VM. Equivalent to AWS instance private IP."
  value       = module.this.private_ip_address
}

output "port" {
  description = "The port number that event-scheduler service listens on. Same as AWS."
  value       = var.event_scheduler.port
}

# Additional Azure-specific outputs
output "public_ip_address" {
  description = "The public IP address of the event-scheduler VM (if assigned)."
  value       = module.this.public_ip_address
}

output "network_security_group_id" {
  description = "The ID of the network security group associated with the VM."
  value       = module.this.network_security_group_id
}

output "private_ip_address" {
  description = "The private IP address of the event-scheduler VM."
  value       = module.this.private_ip_address
}

# Connection Information for Backend Integration
output "connection_info" {
  description = "Connection information for backend services to communicate with event-scheduler."
  value = {
    host     = module.this.private_ip_address
    port     = var.event_scheduler.port
    endpoint = "${module.this.private_ip_address}:${var.event_scheduler.port}"
  }
}
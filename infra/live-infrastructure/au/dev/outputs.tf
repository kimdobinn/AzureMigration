# Frontend Outputs - equivalent to AWS S3 + CloudFront outputs
output "frontend_storage_account_name" {
  description = "Name of the storage account hosting the static website"
  value       = module.frontend.storage_account_name
}

output "frontend_website_urls" {
  description = "URLs for accessing the frontend website"
  value       = module.frontend.website_urls
}

output "frontend_cdn_endpoint" {
  description = "CDN endpoint hostname for the frontend"
  value       = module.frontend.cdn_endpoint_hostname
}

output "frontend_deployment_info" {
  description = "Information needed for CI/CD deployment to the frontend"
  value       = module.frontend.deployment_info
  sensitive   = true
}# Event-Scheduler Outputs - equivalent to AWS event-scheduler outputs
output "event_scheduler_vm_id" {
  description = "ID of the event-scheduler VM"
  value       = module.event_scheduler_vm.id
}

output "event_scheduler_endpoint" {
  description = "Private IP endpoint of the event-scheduler VM"
  value       = module.event_scheduler_vm.endpoint
}

output "event_scheduler_connection_info" {
  description = "Connection information for backend services"
  value       = module.event_scheduler_vm.connection_info
}
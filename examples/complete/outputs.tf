# Module outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.ha_web.vpc_id
}

output "slb_service_url" {
  description = "The HTTP service URL of the load balancer"
  value       = module.ha_web.slb_service_url
}

output "ecs_instance_ids" {
  description = "Map of ECS instance IDs"
  value       = module.ha_web.ecs_instance_ids
}

output "ecs_instance_public_ips" {
  description = "Map of ECS instance public IP addresses"
  value       = module.ha_web.ecs_instance_public_ips
}

output "nas_mount_directories" {
  description = "NAS mount directories on ECS instances"
  value       = module.ha_web.nas_mount_directories
}

output "ecs_console_urls" {
  description = "Console URLs for ECS instances management"
  value       = module.ha_web.ecs_console_urls
}

output "nas_console_urls" {
  description = "Console URLs for NAS file systems management"
  value       = module.ha_web.nas_console_urls
}
# VPC outputs
output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = alicloud_vpc.vpc.vpc_name
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = alicloud_vpc.vpc.cidr_block
}

# VSwitch outputs
output "ecs_vswitch_ids" {
  description = "Map of ECS VSwitch IDs"
  value       = { for k, v in alicloud_vswitch.ecs_vswitches : k => v.id }
}

output "ecs_vswitch_names" {
  description = "Map of ECS VSwitch names"
  value       = { for k, v in alicloud_vswitch.ecs_vswitches : k => v.vswitch_name }
}

output "nas_vswitch_ids" {
  description = "Map of NAS VSwitch IDs"
  value       = { for k, v in alicloud_vswitch.nas_vswitches : k => v.id }
}

output "nas_vswitch_names" {
  description = "Map of NAS VSwitch names"
  value       = { for k, v in alicloud_vswitch.nas_vswitches : k => v.vswitch_name }
}

# Security Group outputs
output "security_group_id" {
  description = "The ID of the security group"
  value       = alicloud_security_group.security_group.id
}

output "security_group_name" {
  description = "The name of the security group"
  value       = alicloud_security_group.security_group.security_group_name
}

# ECS instance outputs
output "ecs_instance_ids" {
  description = "Map of ECS instance IDs"
  value       = { for k, v in alicloud_instance.ecs_instances : k => v.id }
}

output "ecs_instance_names" {
  description = "Map of ECS instance names"
  value       = { for k, v in alicloud_instance.ecs_instances : k => v.instance_name }
}

output "ecs_instance_public_ips" {
  description = "Map of ECS instance public IP addresses"
  value       = { for k, v in alicloud_instance.ecs_instances : k => v.public_ip }
}

output "ecs_instance_private_ips" {
  description = "Map of ECS instance private IP addresses"
  value       = { for k, v in alicloud_instance.ecs_instances : k => v.primary_ip_address }
}

# NAS file system outputs
output "nas_file_system_ids" {
  description = "Map of NAS file system IDs"
  value = {
    master = alicloud_nas_file_system.master_fs.id
    backup = alicloud_nas_file_system.backup_fs.id
  }
}

# NAS mount target outputs
output "nas_mount_target_domains" {
  description = "Map of NAS mount target domains"
  value = {
    master = alicloud_nas_mount_target.master_mt.mount_target_domain
    backup = alicloud_nas_mount_target.backup_mt.mount_target_domain
  }
}

output "nas_mount_directories" {
  description = "NAS mount directories on ECS instances"
  value = {
    master_mount_dir = "/nas_master"
    backup_mount_dir = "/nas_backup"
  }
}

# SLB outputs
output "slb_id" {
  description = "The ID of the SLB load balancer"
  value       = alicloud_slb_load_balancer.slb.id
}

output "slb_name" {
  description = "The name of the SLB load balancer"
  value       = alicloud_slb_load_balancer.slb.load_balancer_name
}

output "slb_address" {
  description = "The public IP address of the SLB load balancer"
  value       = alicloud_slb_load_balancer.slb.address
}

output "slb_service_url" {
  description = "The HTTP service URL of the load balancer"
  value       = format("http://%s", alicloud_slb_load_balancer.slb.address)
}

# ECS command outputs
output "ecs_command_id" {
  description = "The ID of the ECS command"
  value       = alicloud_ecs_command.ecs_command.id
}

output "ecs_command_name" {
  description = "The name of the ECS command"
  value       = alicloud_ecs_command.ecs_command.name
}

# ECS invocation outputs
output "ecs_invocation_id" {
  description = "The ID of the ECS invocation"
  value       = alicloud_ecs_invocation.invocation.id
}

output "ecs_invocation_status" {
  description = "The status of the ECS invocation"
  value       = alicloud_ecs_invocation.invocation.status
}

# Console URLs for resource management
output "ecs_console_urls" {
  description = "Console URLs for ECS instances management"
  value = {
    for k, v in alicloud_instance.ecs_instances : k => format(
      "https://ecs.console.aliyun.com/#/server/region/%s?instanceIds=%s",
      data.alicloud_regions.current.regions[0].id,
      v.id
    )
  }
}

output "nas_console_urls" {
  description = "Console URLs for NAS file systems management"
  value = {
    master = format(
      "https://nasnext.console.aliyun.com/%s/filesystem/%s",
      data.alicloud_regions.current.regions[0].id,
      alicloud_nas_file_system.master_fs.id
    )
    backup = format(
      "https://nasnext.console.aliyun.com/%s/filesystem/%s",
      data.alicloud_regions.current.regions[0].id,
      alicloud_nas_file_system.backup_fs.id
    )
  }
}
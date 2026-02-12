variable "region" {
  description = "The Alibaba Cloud region to deploy resources"
  type        = string
  default     = "cn-shanghai"
}

variable "common_name" {
  description = "Common name prefix for all resources"
  type        = string
  default     = "high-availability-web"
}

variable "ecs_instance_password" {
  description = "Password for ECS instances. Must be 8-30 characters long and contain uppercase letters, lowercase letters, numbers, and special characters"
  type        = string
  sensitive   = true
}
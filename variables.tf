variable "vpc_config" {
  description = "The parameters of VPC. The attribute 'cidr_block' is required."
  type = object({
    vpc_name   = optional(string, "ha-web-vpc")
    cidr_block = string
  })
}

variable "ecs_vswitch_configs" {
  description = "Configuration for ECS VSwitches. Keys should be meaningful identifiers."
  type = map(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, null)
  }))
}

variable "nas_vswitch_configs" {
  description = "Configuration for NAS VSwitches. Keys should be meaningful identifiers."
  type = map(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, null)
  }))

  validation {
    condition     = contains(keys(var.nas_vswitch_configs), "master") && contains(keys(var.nas_vswitch_configs), "backup")
    error_message = "The nas_vswitch_configs map must contain both 'master' and 'backup' keys."
  }
}

variable "security_group_config" {
  description = "The parameters of security group."
  type = object({
    security_group_name = optional(string, "ha-web-sg")
  })
  default = {}
}

variable "security_group_rules_config" {
  description = "Configuration for security group rules. Keys should be meaningful identifiers."
  type = map(object({
    type        = string
    ip_protocol = string
    port_range  = string
    cidr_ip     = string
  }))
  default = {
    http = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "0.0.0.0/0"
    }
    ssh = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "0.0.0.0/0"
    }
  }
}

variable "ecs_instances_config" {
  description = "Configuration for ECS instances."
  type = object({
    instance_name              = optional(string, null)
    image_id                   = string
    instance_type              = string
    internet_max_bandwidth_out = optional(number, 10)
    system_disk_category       = string
  })
  default = {
    image_id             = null
    instance_type        = null
    system_disk_category = null
  }
}

variable "ecs_password" {
  description = "Password for ECS instances. Must be 8-30 characters long and contain uppercase letters, lowercase letters, numbers, and special characters."
  type        = string
  sensitive   = true
}


variable "nas_file_systems" {
  description = "Configuration for NAS file systems."
  type = object({
    master = object({
      protocol_type = optional(string, "NFS")
      storage_type  = optional(string, "Capacity")
      description   = optional(string, null)
      zone_id       = string
    })
    backup = object({
      protocol_type = optional(string, "NFS")
      storage_type  = optional(string, "Capacity")
      description   = optional(string, null)
      zone_id       = string
    })
  })
  default = {
    master = {
      zone_id = null
    }
    backup = {
      zone_id = null
    }
  }
}

variable "nas_mount_targets" {
  description = "Configuration for NAS mount targets."
  type = object({
    master = object({
      access_group_name = optional(string, "DEFAULT_VPC_GROUP_NAME")
      network_type      = optional(string, "Vpc")
    })
    backup = object({
      access_group_name = optional(string, "DEFAULT_VPC_GROUP_NAME")
      network_type      = optional(string, "Vpc")
    })
  })
  default = {
    master = {}
    backup = {}
  }
}

variable "slb_config" {
  description = "The parameters of SLB load balancer."
  type = object({
    load_balancer_name   = optional(string, "ha-web-slb")
    address_type         = optional(string, "internet")
    instance_charge_type = optional(string, "PayByCLCU")
  })
  default = {}
}

variable "slb_backend_server_weight" {
  description = "The weight of each ECS instance in SLB backend server."
  type        = number
  default     = 100
}

variable "slb_listener_config" {
  description = "The parameters of SLB listener."
  type = object({
    backend_port              = optional(number, 80)
    frontend_port             = optional(number, 80)
    protocol                  = optional(string, "http")
    bandwidth                 = optional(number, 10)
    health_check              = optional(string, "on")
    health_check_uri          = optional(string, "/")
    health_check_connect_port = optional(number, 80)
    healthy_threshold         = optional(number, 3)
    unhealthy_threshold       = optional(number, 3)
    health_check_timeout      = optional(number, 5)
    health_check_interval     = optional(number, 2)
    health_check_http_code    = optional(string, "http_2xx,http_3xx,http_4xx,http_5xx")
    request_timeout           = optional(number, 60)
    idle_timeout              = optional(number, 30)
  })
  default = {}
}

variable "ecs_command_config" {
  description = "The parameters of ECS command. The attributes 'name', 'description' and 'type' are required."
  type = object({
    name             = string
    description      = string
    enable_parameter = optional(bool, false)
    type             = string
    timeout          = optional(number, 300)
    working_dir      = optional(string, "/root")
  })
  default = {
    name        = null
    description = null
    type        = null
  }
}

variable "custom_ecs_command_script" {
  description = "Custom ECS command script. If not provided, the default script will be used."
  type        = string
  default     = null
  sensitive   = true
}

variable "ecs_invocation_config" {
  description = "The parameters of ECS invocation."
  type = object({
    create_timeout = optional(string, "5m")
  })
  default = {}
}
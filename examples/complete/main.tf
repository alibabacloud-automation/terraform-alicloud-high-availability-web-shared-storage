provider "alicloud" {
  region = var.region
}

# Data sources for querying available resources
data "alicloud_zones" "default" {
  available_instance_type     = data.alicloud_instance_types.default.ids[0]
  available_resource_creation = "VSwitch"
}

data "alicloud_instance_types" "default" {
  instance_type_family = "ecs.g7"
  sorted_by            = "CPU"
}

data "alicloud_images" "default" {
  name_regex  = "^aliyun_3_9_x64_20G_*"
  most_recent = true
  owners      = "system"
}

data "alicloud_nas_zones" "default" {
  file_system_type = "standard"
}

# Local variables for NAS zone calculation
locals {

  # Calculate valid NAS zones based on zone configuration
  valid_nas_zones = [
    for zone in data.alicloud_nas_zones.default.zones : zone.zone_id
    if anytrue([
      for t in zone.instance_types :
      t.protocol_type == "nfs" && t.storage_type == "Capacity"
    ])
  ]

  vswitch_zones = toset([for z in data.alicloud_zones.default.zones : z.id])

  # 取交集
  valid_nas_zones_final = tolist(setintersection(local.valid_nas_zones, local.vswitch_zones))


  # Determine NAS target zones - use first two if available, otherwise repeat first zone
  nas_target_zones = length(local.valid_nas_zones_final) >= 2 ? slice(local.valid_nas_zones_final, 0, 2) : (
    length(local.valid_nas_zones_final) == 1 ? [local.valid_nas_zones_final[0], local.valid_nas_zones_final[0]] : ["invalid-zone", "invalid-zone"]
  )
}

# Use the ha-web module
module "ha_web" {
  source = "../../"

  # VPC configuration
  vpc_config = {
    vpc_name   = var.common_name
    cidr_block = "192.168.0.0/16"
  }

  # ECS VSwitch configurations
  ecs_vswitch_configs = {
    ecs_vswitch1 = {
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "${var.common_name}-ecs-vsw-1"
    }
    ecs_vswitch2 = {
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "${var.common_name}-ecs-vsw-2"
    }
  }

  # NAS VSwitch configurations
  nas_vswitch_configs = {
    master = {
      cidr_block   = "192.168.3.0/24"
      zone_id      = local.nas_target_zones[0]
      vswitch_name = "${var.common_name}-nas-vsw-master"
    }
    backup = {
      cidr_block   = "192.168.4.0/24"
      zone_id      = local.nas_target_zones[1]
      vswitch_name = "${var.common_name}-nas-vsw-backup"
    }
  }

  # Security group configuration
  security_group_config = {
    security_group_name = "${var.common_name}-sg"
  }

  # Security group rules
  security_group_rules_config = {
    http = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "80/80"
      cidr_ip     = "192.168.0.0/16"
    }
    ssh = {
      type        = "ingress"
      ip_protocol = "tcp"
      port_range  = "22/22"
      cidr_ip     = "192.168.0.0/16"
    }
  }

  # ECS instances configuration
  ecs_instances_config = {
    instance_name              = var.common_name
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    internet_max_bandwidth_out = 10
    system_disk_category       = "cloud_essd"
  }

  # ECS password
  ecs_password = var.ecs_instance_password

  # NAS file systems configuration
  nas_file_systems = {
    master = {
      protocol_type = "NFS"
      storage_type  = "Capacity"
      description   = "MasterNAS"
      zone_id       = local.nas_target_zones[0]
    }
    backup = {
      protocol_type = "NFS"
      storage_type  = "Capacity"
      description   = "BackupNAS"
      zone_id       = local.nas_target_zones[1]
    }
  }

  # NAS mount targets configuration
  nas_mount_targets = {
    master = {
      access_group_name = "DEFAULT_VPC_GROUP_NAME"
      network_type      = "Vpc"
    }
    backup = {
      access_group_name = "DEFAULT_VPC_GROUP_NAME"
      network_type      = "Vpc"
    }
  }

  # SLB configuration
  slb_config = {
    load_balancer_name   = "${var.common_name}-slb"
    address_type         = "internet"
    instance_charge_type = "PayByCLCU"
  }

  # SLB backend server weight
  slb_backend_server_weight = 100

  # ECS command configuration
  ecs_command_config = {
    name             = "${var.common_name}-command"
    description      = "ECS initialization command"
    enable_parameter = false
    type             = "RunShellScript"
    timeout          = 300
    working_dir      = "/root"
  }

  # ECS invocation configuration
  ecs_invocation_config = {
    create_timeout = "5m"
  }
}
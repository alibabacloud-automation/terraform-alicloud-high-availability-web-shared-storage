High Availability and Shared Storage Web Service Terraform Module

================================================ 

# terraform-alicloud-ha-web-service

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-ha-web-service/blob/main/README-CN.md)

This Terraform module creates a high availability and shared storage web service infrastructure on Alibaba Cloud. The module implements the [high availability and shared storage web services](https://www.aliyun.com/solution/tech-solution/ha-web) solution, involving the creation, configuration, and deployment of resources such as Virtual Private Cloud (VPC), Virtual Switch (VSwitch), Elastic Compute Service (ECS), Load Balancer (CLB), and File Storage NAS. This solution provides a scalable and resilient web architecture with shared storage capabilities for web applications.

## Usage

This module creates a complete high availability web service infrastructure including VPC networking, multiple ECS instances, NAS shared storage, and load balancing capabilities.

```terraform
data "alicloud_zones" "default" {
  available_instance_type = "ecs.g7.large"
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

module "ha_web_service" {
  source = "alibabacloud-automation/ha-web-service/alicloud"

  # VPC configuration
  vpc_config = {
    vpc_name   = "my-ha-web-vpc"
    cidr_block = "192.168.0.0/16"
  }

  # VSwitch configurations
  vswitch_configs = {
    ecs_vswitch1 = {
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-ha-web-vsw-1"
    }
    ecs_vswitch2 = {
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-ha-web-vsw-2"
    }
  }

  # ECS instances configuration
  ecs_instances_config = {
    ecs_instance1 = {
      instance_name = "my-ha-web-ecs-1"
      vswitch_key   = "ecs_vswitch1"
    }
    ecs_instance2 = {
      instance_name = "my-ha-web-ecs-2"
      vswitch_key   = "ecs_vswitch2"
    }
  }

  # ECS instance configuration
  instance_config = {
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    system_disk_category       = "cloud_essd"
    password                   = "YourPassword123!"
  }

  # NAS zones configuration
  nas_zones = data.alicloud_nas_zones.default.zones

  # ECS command configuration
  ecs_command_config = {
    name        = "ha-web-command"
    description = "ECS initialization command"
    type        = "RunShellScript"
  }
}
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-ha-web-service/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
高可用及共享存储 Web 服务 Terraform 模块

================================================ 

# terraform-alicloud-ha-web-service

[English](https://github.com/alibabacloud-automation/terraform-alicloud-ha-web-service/blob/main/README.md) | 简体中文

该 Terraform 模块在阿里云上创建高可用及共享存储 Web 服务基础设施。该模块实现了[高可用及共享存储 Web 服务](https://www.aliyun.com/solution/tech-solution/ha-web)解决方案，涉及专有网络（VPC）、交换机（VSwitch）、云服务器（ECS）、负载均衡（CLB）、文件存储（NAS）等资源的创建、配置和部署。该解决方案为 Web 应用程序提供了具有共享存储功能的可扩展和弹性的 Web 架构。

## 使用方法

该模块创建完整的高可用 Web 服务基础设施，包括 VPC 网络、多个 ECS 实例、NAS 共享存储和负载均衡功能。

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

  # VPC 配置
  vpc_config = {
    vpc_name   = "my-ha-web-vpc"
    cidr_block = "192.168.0.0/16"
  }

  # VSwitch 配置
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

  # ECS 实例配置
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

  # ECS 实例配置
  instance_config = {
    image_id                   = data.alicloud_images.default.images[0].id
    instance_type              = data.alicloud_instance_types.default.instance_types[0].id
    system_disk_category       = "cloud_essd"
    password                   = "YourPassword123!"
  }

  # NAS 可用区配置
  nas_zones = data.alicloud_nas_zones.default.zones

  # ECS 命令配置
  ecs_command_config = {
    name        = "ha-web-command"
    description = "ECS initialization command"
    type        = "RunShellScript"
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-ha-web-service/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)
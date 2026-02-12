高可用及共享存储 Web 服务 Terraform 模块

# terraform-alicloud-high-availability-web-shared-storage

[English](https://github.com/alibabacloud-automation/terraform-alicloud-high-availability-web-shared-storage/blob/main/README.md) | 简体中文

该 Terraform 模块在阿里云上创建高可用及共享存储 Web 服务基础设施。该模块实现了[高可用及共享存储 Web 服务](https://www.aliyun.com/solution/tech-solution/ha-web)解决方案，涉及专有网络（VPC）、交换机（VSwitch）、云服务器（ECS）、负载均衡（CLB）、文件存储（NAS）等资源的创建、配置和部署。该解决方案为 Web 应用程序提供了具有共享存储功能的可扩展和弹性的 Web 架构。

## 使用方法

该模块创建完整的高可用 Web 服务基础设施，包括 VPC 网络、多个 ECS 实例、NAS 共享存储和负载均衡功能。

```terraform
data "alicloud_zones" "default" {
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

module "ha_web_service" {
  source = "alibabacloud-automation/high-availability-web-shared-storage/alicloud"

  # VPC 配置
  vpc_config = {
    vpc_name   = "my-ha-web-vpc"
    cidr_block = "192.168.0.0/16"
  }

  # ECS 交换机配置
  ecs_vswitch_configs = {
    ecs_vswitch1 = {
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-ha-web-ecs-vsw-1"
    }
    ecs_vswitch2 = {
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-ha-web-ecs-vsw-2"
    }
  }

  # NAS 交换机配置
  nas_vswitch_configs = {
    master = {
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-ha-web-nas-vsw-master"
    }
    backup = {
      cidr_block   = "192.168.4.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "my-ha-web-nas-vsw-backup"
    }
  }

  # ECS 实例配置
  ecs_instances_config = {
    instance_name        = "my-ha-web-ecs"
    image_id             = data.alicloud_images.default.images[0].id
    instance_type        = data.alicloud_instance_types.default.instance_types[0].id
    system_disk_category = "cloud_essd"
  }

  # ECS 密码
  ecs_password = "YourPassword123!"

  # NAS 文件系统配置
  nas_file_systems = {
    master = {
      zone_id = data.alicloud_zones.default.zones[0].id
    }
    backup = {
      zone_id = data.alicloud_zones.default.zones[0].id
    }
  }

  # ECS 命令配置
  ecs_command_config = {
    name        = "ha-web-command"
    description = "ECS initialization command"
    type        = "RunShellScript"
  }
}
```

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-high-availability-web-shared-storage/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_alicloud"></a> [alicloud](#requirement\_alicloud) | >= 1.212.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | >= 1.212.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_ecs_command.ecs_command](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_command) | resource |
| [alicloud_ecs_invocation.invocation](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/ecs_invocation) | resource |
| [alicloud_instance.ecs_instances](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/instance) | resource |
| [alicloud_nas_file_system.backup_fs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nas_file_system) | resource |
| [alicloud_nas_file_system.master_fs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nas_file_system) | resource |
| [alicloud_nas_mount_target.backup_mt](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nas_mount_target) | resource |
| [alicloud_nas_mount_target.master_mt](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/nas_mount_target) | resource |
| [alicloud_security_group.security_group](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_security_group_rule.security_group_rules](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group_rule) | resource |
| [alicloud_slb_backend_server.slb_backend](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/slb_backend_server) | resource |
| [alicloud_slb_listener.http_listener](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/slb_listener) | resource |
| [alicloud_slb_load_balancer.slb](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/slb_load_balancer) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.ecs_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_vswitch.nas_vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |
| [alicloud_regions.current](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/data-sources/regions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_ecs_command_script"></a> [custom\_ecs\_command\_script](#input\_custom\_ecs\_command\_script) | Custom ECS command script. If not provided, the default script will be used. | `string` | `null` | no |
| <a name="input_ecs_command_config"></a> [ecs\_command\_config](#input\_ecs\_command\_config) | The parameters of ECS command. The attributes 'name', 'description' and 'type' are required. | <pre>object({<br/>    name             = string<br/>    description      = string<br/>    enable_parameter = optional(bool, false)<br/>    type             = string<br/>    timeout          = optional(number, 300)<br/>    working_dir      = optional(string, "/root")<br/>  })</pre> | <pre>{<br/>  "description": null,<br/>  "name": null,<br/>  "type": null<br/>}</pre> | no |
| <a name="input_ecs_instances_config"></a> [ecs\_instances\_config](#input\_ecs\_instances\_config) | Configuration for ECS instances. | <pre>object({<br/>    instance_name              = optional(string, null)<br/>    image_id                   = string<br/>    instance_type              = string<br/>    internet_max_bandwidth_out = optional(number, 10)<br/>    system_disk_category       = string<br/>  })</pre> | <pre>{<br/>  "image_id": null,<br/>  "instance_type": null,<br/>  "system_disk_category": null<br/>}</pre> | no |
| <a name="input_ecs_invocation_config"></a> [ecs\_invocation\_config](#input\_ecs\_invocation\_config) | The parameters of ECS invocation. | <pre>object({<br/>    create_timeout = optional(string, "5m")<br/>  })</pre> | `{}` | no |
| <a name="input_ecs_password"></a> [ecs\_password](#input\_ecs\_password) | Password for ECS instances. Must be 8-30 characters long and contain uppercase letters, lowercase letters, numbers, and special characters. | `string` | n/a | yes |
| <a name="input_ecs_vswitch_configs"></a> [ecs\_vswitch\_configs](#input\_ecs\_vswitch\_configs) | Configuration for ECS VSwitches. Keys should be meaningful identifiers. | <pre>map(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_nas_file_systems"></a> [nas\_file\_systems](#input\_nas\_file\_systems) | Configuration for NAS file systems. | <pre>object({<br/>    master = object({<br/>      protocol_type = optional(string, "NFS")<br/>      storage_type  = optional(string, "Capacity")<br/>      description   = optional(string, null)<br/>      zone_id       = string<br/>    })<br/>    backup = object({<br/>      protocol_type = optional(string, "NFS")<br/>      storage_type  = optional(string, "Capacity")<br/>      description   = optional(string, null)<br/>      zone_id       = string<br/>    })<br/>  })</pre> | <pre>{<br/>  "backup": {<br/>    "zone_id": null<br/>  },<br/>  "master": {<br/>    "zone_id": null<br/>  }<br/>}</pre> | no |
| <a name="input_nas_mount_targets"></a> [nas\_mount\_targets](#input\_nas\_mount\_targets) | Configuration for NAS mount targets. | <pre>object({<br/>    master = object({<br/>      access_group_name = optional(string, "DEFAULT_VPC_GROUP_NAME")<br/>      network_type      = optional(string, "Vpc")<br/>    })<br/>    backup = object({<br/>      access_group_name = optional(string, "DEFAULT_VPC_GROUP_NAME")<br/>      network_type      = optional(string, "Vpc")<br/>    })<br/>  })</pre> | <pre>{<br/>  "backup": {},<br/>  "master": {}<br/>}</pre> | no |
| <a name="input_nas_vswitch_configs"></a> [nas\_vswitch\_configs](#input\_nas\_vswitch\_configs) | Configuration for NAS VSwitches. Keys should be meaningful identifiers. | <pre>map(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, null)<br/>  }))</pre> | n/a | yes |
| <a name="input_security_group_config"></a> [security\_group\_config](#input\_security\_group\_config) | The parameters of security group. | <pre>object({<br/>    security_group_name = optional(string, "ha-web-sg")<br/>  })</pre> | `{}` | no |
| <a name="input_security_group_rules_config"></a> [security\_group\_rules\_config](#input\_security\_group\_rules\_config) | Configuration for security group rules. Keys should be meaningful identifiers. | <pre>map(object({<br/>    type        = string<br/>    ip_protocol = string<br/>    port_range  = string<br/>    cidr_ip     = string<br/>  }))</pre> | <pre>{<br/>  "http": {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "80/80",<br/>    "type": "ingress"<br/>  },<br/>  "ssh": {<br/>    "cidr_ip": "0.0.0.0/0",<br/>    "ip_protocol": "tcp",<br/>    "port_range": "22/22",<br/>    "type": "ingress"<br/>  }<br/>}</pre> | no |
| <a name="input_slb_backend_server_weight"></a> [slb\_backend\_server\_weight](#input\_slb\_backend\_server\_weight) | The weight of each ECS instance in SLB backend server. | `number` | `100` | no |
| <a name="input_slb_config"></a> [slb\_config](#input\_slb\_config) | The parameters of SLB load balancer. | <pre>object({<br/>    load_balancer_name   = optional(string, "ha-web-slb")<br/>    address_type         = optional(string, "internet")<br/>    instance_charge_type = optional(string, "PayByCLCU")<br/>  })</pre> | `{}` | no |
| <a name="input_slb_listener_config"></a> [slb\_listener\_config](#input\_slb\_listener\_config) | The parameters of SLB listener. | <pre>object({<br/>    backend_port              = optional(number, 80)<br/>    frontend_port             = optional(number, 80)<br/>    protocol                  = optional(string, "http")<br/>    bandwidth                 = optional(number, 10)<br/>    health_check              = optional(string, "on")<br/>    health_check_uri          = optional(string, "/")<br/>    health_check_connect_port = optional(number, 80)<br/>    healthy_threshold         = optional(number, 3)<br/>    unhealthy_threshold       = optional(number, 3)<br/>    health_check_timeout      = optional(number, 5)<br/>    health_check_interval     = optional(number, 2)<br/>    health_check_http_code    = optional(string, "http_2xx,http_3xx,http_4xx,http_5xx")<br/>    request_timeout           = optional(number, 60)<br/>    idle_timeout              = optional(number, 30)<br/>  })</pre> | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | The parameters of VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    vpc_name   = optional(string, "ha-web-vpc")<br/>    cidr_block = string<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_command_id"></a> [ecs\_command\_id](#output\_ecs\_command\_id) | The ID of the ECS command |
| <a name="output_ecs_command_name"></a> [ecs\_command\_name](#output\_ecs\_command\_name) | The name of the ECS command |
| <a name="output_ecs_console_urls"></a> [ecs\_console\_urls](#output\_ecs\_console\_urls) | Console URLs for ECS instances management |
| <a name="output_ecs_instance_ids"></a> [ecs\_instance\_ids](#output\_ecs\_instance\_ids) | Map of ECS instance IDs |
| <a name="output_ecs_instance_names"></a> [ecs\_instance\_names](#output\_ecs\_instance\_names) | Map of ECS instance names |
| <a name="output_ecs_instance_private_ips"></a> [ecs\_instance\_private\_ips](#output\_ecs\_instance\_private\_ips) | Map of ECS instance private IP addresses |
| <a name="output_ecs_instance_public_ips"></a> [ecs\_instance\_public\_ips](#output\_ecs\_instance\_public\_ips) | Map of ECS instance public IP addresses |
| <a name="output_ecs_invocation_id"></a> [ecs\_invocation\_id](#output\_ecs\_invocation\_id) | The ID of the ECS invocation |
| <a name="output_ecs_invocation_status"></a> [ecs\_invocation\_status](#output\_ecs\_invocation\_status) | The status of the ECS invocation |
| <a name="output_ecs_vswitch_ids"></a> [ecs\_vswitch\_ids](#output\_ecs\_vswitch\_ids) | Map of ECS VSwitch IDs |
| <a name="output_ecs_vswitch_names"></a> [ecs\_vswitch\_names](#output\_ecs\_vswitch\_names) | Map of ECS VSwitch names |
| <a name="output_nas_console_urls"></a> [nas\_console\_urls](#output\_nas\_console\_urls) | Console URLs for NAS file systems management |
| <a name="output_nas_file_system_ids"></a> [nas\_file\_system\_ids](#output\_nas\_file\_system\_ids) | Map of NAS file system IDs |
| <a name="output_nas_mount_directories"></a> [nas\_mount\_directories](#output\_nas\_mount\_directories) | NAS mount directories on ECS instances |
| <a name="output_nas_mount_target_domains"></a> [nas\_mount\_target\_domains](#output\_nas\_mount\_target\_domains) | Map of NAS mount target domains |
| <a name="output_nas_vswitch_ids"></a> [nas\_vswitch\_ids](#output\_nas\_vswitch\_ids) | Map of NAS VSwitch IDs |
| <a name="output_nas_vswitch_names"></a> [nas\_vswitch\_names](#output\_nas\_vswitch\_names) | Map of NAS VSwitch names |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the security group |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the security group |
| <a name="output_slb_address"></a> [slb\_address](#output\_slb\_address) | The public IP address of the SLB load balancer |
| <a name="output_slb_id"></a> [slb\_id](#output\_slb\_id) | The ID of the SLB load balancer |
| <a name="output_slb_name"></a> [slb\_name](#output\_slb\_name) | The name of the SLB load balancer |
| <a name="output_slb_service_url"></a> [slb\_service\_url](#output\_slb\_service\_url) | The HTTP service URL of the load balancer |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | The name of the VPC |
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
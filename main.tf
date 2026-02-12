# Data sources for current region information
data "alicloud_regions" "current" {
  current = true
}

# Local variables for complex logic and default configurations
locals {
  # Default ECS initialization script
  default_ecs_command_script = <<-SHELL
    #!/bin/bash
    if [ ! -f .ros.provision ]; then
      echo "Name: 高可用及共享存储Web服务" > .ros.provision
    fi

    name=$(grep "^Name:" .ros.provision | awk -F':' '{print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    if [[ "$name" != "高可用及共享存储Web服务" ]]; then
      echo "当前实例已使用过\"$name\"教程的一键配置，不能再使用本教程的一键配置"
      exit 0
    fi

    echo "#########################"
    echo "# Check Network"
    echo "#########################"
    ping -c 2 -W 2 aliyun.com > /dev/null
    if [[ $? -ne 0 ]]; then
      echo "当前实例无法访问公网"
      exit 0
    fi

    if ! grep -q "^Step1: Prepare Environment$" .ros.provision; then
      echo "#########################"
      echo "# Prepare Environment"
      echo "#########################"
      systemctl status firewalld
      systemctl stop firewalld
      echo "Step1: Prepare Environment" >> .ros.provision
    else
      echo "#########################"
      echo "# Environment has been ready"
      echo "#########################"
    fi

    if ! grep -q "^Step2: Install Nginx and deploy service$" .ros.provision; then
      echo "#########################"
      echo "# Install Nginx"
      echo "#########################"
      sudo yum -y install nginx
      sudo wget -O /usr/share/nginx/html/index.html https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/file-manage-files/zh-CN/20231013/jhgg/index.html
      sudo wget -O /usr/share/nginx/html/lipstick.png https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/file-manage-files/zh-CN/20230925/zevs/lipstick.png
      sudo systemctl start nginx
      sudo systemctl enable nginx
      echo "Step2: Install Nginx and deploy service" >> .ros.provision
    else
      echo "#########################"
      echo "# Nginx has been installed"
      echo "#########################"
    fi

    if ! grep -q "^Step3: Mount to the ECS" .ros.provision; then
      echo "#########################"
      echo "# Mount to the ECS"
      echo "#########################"
      mkdir /nas_master
      mkdir /nas_backup
      sudo yum install -y nfs-utils
      sudo echo "options sunrpc tcp_slot_table_entries=128" >>  /etc/modprobe.d/sunrpc.conf
      sudo echo "options sunrpc tcp_max_slot_table_entries=128" >>  /etc/modprobe.d/sunrpc.conf
      sudo mount -t nfs -o vers=3,nolock,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${alicloud_nas_mount_target.master_mt.mount_target_domain}:/ /nas_master
      sudo mount -t nfs -o vers=3,nolock,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${alicloud_nas_mount_target.backup_mt.mount_target_domain}:/ /nas_backup

      sudo echo "${alicloud_nas_mount_target.master_mt.mount_target_domain}:/ /nas_master nfs vers=3,nolock,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0" >> /etc/fstab

      sudo echo "${alicloud_nas_mount_target.backup_mt.mount_target_domain}:/ /nas_backup nfs vers=3,nolock,proto=tcp,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport 0 0" >> /etc/fstab

      df -h | grep aliyun
    else
      echo "#########################"
      echo "# The ECS has been attached to the Nas"
      echo "#########################"
    fi

    if ! grep -q "^Step4: Shared file$" .ros.provision; then
      echo "#########################"
      echo "# Shared file"
      echo "#########################"
      sudo cp -Lvr /usr/share/nginx/html /nas_master
      sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
      echo "Step4: Shared file" >> .ros.provision
    else
      echo "#########################"
      echo "# File has been Shared"
      echo "#########################"
    fi

    if ! grep -q "^Step5: Install inotify-tools、rsync$" .ros.provision; then
      echo "#########################"
      echo "# Install inotify-tools、rsync"
      echo "#########################"
      sudo yum install -y inotify-tools rsync
      echo "Step6: Install inotify-tools、rsync" >> .ros.provision
    else
      echo "#########################"
      echo "# Inotify-tools has been installed"
      echo "#########################"
    fi
    if ! grep -q "^Step6: Install synchronization server$" .ros.provision; then
      echo "#########################"
      echo "# Install synchronization server"
      echo "#########################"
      sudo wget -P /etc/systemd/system/ https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/file-manage-files/zh-CN/20231017/pftz/sync_nas.sh
      sudo wget -P /etc/systemd/system/ https://static-aliyun-doc.oss-cn-hangzhou.aliyuncs.com/file-manage-files/en-US/20230925/wmaj/sync_check_switch.sh
      sudo chmod +x /etc/systemd/system/sync_nas.sh
      sudo chmod +x /etc/systemd/system/sync_check_switch.sh
      cat > /etc/systemd/system/sync-check-switch.service <<\EOF
    [Unit]
    Description=Sync Check Switch
    After=network.target

    [Service]
    ExecStart=/etc/systemd/system/sync_check_switch.sh
    RestartSec=3
    Restart=always

    [Install]
    WantedBy=default.target
    EOF

      cat > /etc/systemd/system/sync-nas.service <<\EOF
    [Unit]
    Description=Sync NAS Service
    After=network.target

    [Service]
    ExecStart=/etc/systemd/system/sync_nas.sh
    Restart=always
    RestartSec=3

    [Install]
    WantedBy=default.target
    EOF

      sudo systemctl daemon-reload
      sudo systemctl start sync-nas.service
      sudo systemctl enable sync-check-switch.service
      sudo systemctl start sync-check-switch.service
      sudo systemctl enable sync-nas.service
      echo "Step6: Install " >> .ros.provision
    else
      echo "#########################"
      echo "# Synchronization server has been installed"
      echo "#########################"
    fi
  SHELL
}

# VPC resource
resource "alicloud_vpc" "vpc" {
  vpc_name   = var.vpc_config.vpc_name
  cidr_block = var.vpc_config.cidr_block
}

# ECS VSwitch resources using for_each for aggregation
resource "alicloud_vswitch" "ecs_vswitches" {
  for_each = var.ecs_vswitch_configs

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
}

# NAS VSwitch resources using for_each for aggregation
resource "alicloud_vswitch" "nas_vswitches" {
  for_each = var.nas_vswitch_configs

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
}

# Security Group
resource "alicloud_security_group" "security_group" {
  security_group_name = var.security_group_config.security_group_name
  vpc_id              = alicloud_vpc.vpc.id
}

# Security Group Rules using for_each for aggregation
resource "alicloud_security_group_rule" "security_group_rules" {
  for_each = var.security_group_rules_config

  security_group_id = alicloud_security_group.security_group.id
  type              = each.value.type
  ip_protocol       = each.value.ip_protocol
  port_range        = each.value.port_range
  cidr_ip           = each.value.cidr_ip
}

# ECS instances using for_each for aggregation
resource "alicloud_instance" "ecs_instances" {
  for_each = alicloud_vswitch.ecs_vswitches

  instance_name              = var.ecs_instances_config.instance_name
  image_id                   = var.ecs_instances_config.image_id
  instance_type              = var.ecs_instances_config.instance_type
  internet_max_bandwidth_out = var.ecs_instances_config.internet_max_bandwidth_out
  security_groups            = [alicloud_security_group.security_group.id]
  vswitch_id                 = each.value.id
  system_disk_category       = var.ecs_instances_config.system_disk_category
  password                   = var.ecs_password
}

# Master NAS file system
resource "alicloud_nas_file_system" "master_fs" {
  protocol_type = var.nas_file_systems.master.protocol_type
  storage_type  = var.nas_file_systems.master.storage_type
  description   = var.nas_file_systems.master.description
  zone_id       = var.nas_file_systems.master.zone_id
}

# Backup NAS file system
resource "alicloud_nas_file_system" "backup_fs" {
  protocol_type = var.nas_file_systems.backup.protocol_type
  storage_type  = var.nas_file_systems.backup.storage_type
  description   = var.nas_file_systems.backup.description
  zone_id       = var.nas_file_systems.backup.zone_id
}

# Master NAS mount target
resource "alicloud_nas_mount_target" "master_mt" {
  file_system_id    = alicloud_nas_file_system.master_fs.id
  access_group_name = var.nas_mount_targets.master.access_group_name
  network_type      = var.nas_mount_targets.master.network_type
  vswitch_id        = alicloud_vswitch.nas_vswitches["master"].id
}

# Backup NAS mount target
resource "alicloud_nas_mount_target" "backup_mt" {
  file_system_id    = alicloud_nas_file_system.backup_fs.id
  access_group_name = var.nas_mount_targets.backup.access_group_name
  network_type      = var.nas_mount_targets.backup.network_type
  vswitch_id        = alicloud_vswitch.nas_vswitches["backup"].id
}

# SLB Load Balancer
resource "alicloud_slb_load_balancer" "slb" {
  load_balancer_name   = var.slb_config.load_balancer_name
  address_type         = var.slb_config.address_type
  instance_charge_type = var.slb_config.instance_charge_type
}

# SLB Backend Server
resource "alicloud_slb_backend_server" "slb_backend" {
  load_balancer_id = alicloud_slb_load_balancer.slb.id

  dynamic "backend_servers" {
    for_each = alicloud_instance.ecs_instances
    content {
      server_id = backend_servers.value.id
      weight    = var.slb_backend_server_weight
    }
  }
}

# SLB Listener
resource "alicloud_slb_listener" "http_listener" {
  load_balancer_id          = alicloud_slb_load_balancer.slb.id
  backend_port              = var.slb_listener_config.backend_port
  frontend_port             = var.slb_listener_config.frontend_port
  protocol                  = var.slb_listener_config.protocol
  bandwidth                 = var.slb_listener_config.bandwidth
  health_check              = var.slb_listener_config.health_check
  health_check_uri          = var.slb_listener_config.health_check_uri
  health_check_connect_port = var.slb_listener_config.health_check_connect_port
  healthy_threshold         = var.slb_listener_config.healthy_threshold
  unhealthy_threshold       = var.slb_listener_config.unhealthy_threshold
  health_check_timeout      = var.slb_listener_config.health_check_timeout
  health_check_interval     = var.slb_listener_config.health_check_interval
  health_check_http_code    = var.slb_listener_config.health_check_http_code
  request_timeout           = var.slb_listener_config.request_timeout
  idle_timeout              = var.slb_listener_config.idle_timeout

  lifecycle {
    ignore_changes = [acl_status, acl_type]
  }
}

# ECS Command
resource "alicloud_ecs_command" "ecs_command" {
  name             = var.ecs_command_config.name
  description      = var.ecs_command_config.description
  enable_parameter = var.ecs_command_config.enable_parameter
  type             = var.ecs_command_config.type
  command_content  = base64encode(var.custom_ecs_command_script != null ? var.custom_ecs_command_script : local.default_ecs_command_script)
  timeout          = var.ecs_command_config.timeout
  working_dir      = var.ecs_command_config.working_dir
}

# ECS Invocation
resource "alicloud_ecs_invocation" "invocation" {
  instance_id = [for k, v in alicloud_instance.ecs_instances : v.id]
  command_id  = alicloud_ecs_command.ecs_command.id

  timeouts {
    create = var.ecs_invocation_config.create_timeout
  }
}
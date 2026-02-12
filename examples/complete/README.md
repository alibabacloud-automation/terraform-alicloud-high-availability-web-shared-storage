# Complete Example

This example demonstrates how to use the High Availability Web Service module to deploy a complete web infrastructure with the following components:

- VPC and multiple VSwitches across different availability zones
- Security groups with HTTP and SSH access rules
- Multiple ECS instances for high availability
- NAS file systems for shared storage
- SLB load balancer for traffic distribution
- Automated ECS initialization with Nginx and NAS mounting

## Usage

To run this example:

1. Set up your Alibaba Cloud credentials and region
2. Set the required variables
3. Run terraform commands

### Prerequisites

- Terraform >= 1.0
- Alibaba Cloud Provider >= 1.212.0
- Valid Alibaba Cloud credentials

### Variables

You must provide the following variables:

- `ecs_instance_password`: Password for ECS instances (8-30 characters, must contain uppercase, lowercase, numbers, and special characters)

Optional variables:

- `region`: Alibaba Cloud region (default: "cn-hangzhou")
- `common_name`: Common name prefix for resources (default: "high-availability-web")
- `instance_type`: ECS instance type for zone queries (default: "ecs.g7.large")

### Example terraform.tfvars

```hcl
region                = "cn-hangzhou"
common_name          = "my-ha-web"
ecs_instance_password = "MyPassword123!"
```

### Commands

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Destroy the resources
terraform destroy
```

### Outputs

After deployment, you will get:

- `slb_service_url`: The HTTP URL to access your web service
- `ecs_instance_ids`: IDs of the created ECS instances
- `ecs_console_urls`: Direct links to manage ECS instances in the console
- `nas_console_urls`: Direct links to manage NAS file systems in the console

### Architecture

This example creates:

1. **Network Infrastructure**:
   - 1 VPC with CIDR 192.168.0.0/16
   - 4 VSwitches in different zones for ECS and NAS

2. **Compute Resources**:
   - 2 ECS instances for high availability
   - Automated Nginx installation and configuration

3. **Storage**:
   - 2 NAS file systems (master and backup)
   - Automatic NFS mounting on ECS instances

4. **Load Balancing**:
   - Internet-facing SLB with health checks
   - Backend servers configured with equal weights

5. **Security**:
   - Security group allowing HTTP (80) and SSH (22) access
   - VPC isolation for internal communication

### Notes

- The ECS instances will be automatically configured with Nginx and NAS mounting
- The NAS file systems provide shared storage between instances
- The SLB provides high availability and load distribution
- All resources are tagged and named consistently for easy management
# Radware Alteon ADC Deployment on OpenStack with Terraform

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D0.14-blueviolet)](https://www.terraform.io/)
[![OpenStack Provider](https://img.shields.io/badge/OpenStack%20Provider-~%3E%201.53.0-red)](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest)

This Terraform project automates the deployment of a Radware Alteon ADC (Application Delivery Controller) instance on OpenStack with a complete three-tier network architecture including management, data, and server networks.

## 🚀 Features

- **Three-tier network architecture** with dedicated management, data, and server networks
- **Security groups** with appropriate rules for each network interface
- **Floating IP** for external management access
- **Customizable network CIDRs** and IP addressing
- **Cloud-init configuration** for automated Alteon setup
- **Comprehensive variable configuration** for different deployment scenarios
- **Support for GEL** (Global Elastic Load Balancer) configuration
- **Multiple deployment support** with unique deployment IDs

## 📋 Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads.html) >= 0.14
- [OpenStack Terraform Provider](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest) ~> 1.53.0
- [OpenStack CLI](https://docs.openstack.org/python-openstackclient/latest/) (python-openstackclient)
- Access to an OpenStack cloud environment
- SSH key pair for instance access

### OpenStack Requirements
- OpenStack environment with the following services:
  - Nova (Compute)
  - Neutron (Networking)
  - Glance (Images)
- Alteon image uploaded to Glance
- Sufficient quota for:
  - 1 compute instance (minimum 4 vCPU, 8GB RAM)
  - 3 networks and subnets
  - 1 router
  - 1 floating IP
  - Multiple security groups and ports

## 🛠️ Installation & Setup

### 1. Install Dependencies

#### Install OpenStack CLI

**Windows (PowerShell):**
```powershell
pip install python-openstackclient
```

**macOS:**
```bash
brew install openstackclient
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install python3-openstackclient
```

### 2. Configure OpenStack Authentication

Create your `clouds.yaml` file at `~/.config/openstack/clouds.yaml`:

```yaml
clouds:
  openstack:
    auth:
      auth_url: https://your-openstack-endpoint:5000
      username: "your-username"
      project_id: "your-project-id"
      project_name: "your-project-name"
      user_domain_name: "Default"
      password: "your-password"  # Required for API access
    region_name: "RegionOne"
    interface: "public"
    identity_api_version: 3
```

**⚠️ Security Note:** Never commit your `clouds.yaml` file to version control as it contains credentials.

### 3. Verify OpenStack Access

Test your OpenStack connection:

```bash
openstack server list
openstack image list
openstack network list
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/openstack-alteon-provisioning.git
cd openstack-alteon-provisioning
```

### 2. Configure Variables

Copy the example configuration:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your environment-specific values:

```hcl
# Required: Update these for your environment
external_network_name = "public"                    # Your external network name
alteon_image_name     = "AlteonOSU18-34.5.3.1"    # Your Alteon image name
instance_flavor       = "m1.large"                  # Available flavor
key_pair_name         = "my-keypair"                # Your SSH key pair
availability_zone     = "nova"                      # Your AZ

# Optional: Customize as needed
deployment_id         = "production"
admin_password        = "yourSecurePassword123"
```

### 3. Discover Available Resources

Use these commands to find available resources in your OpenStack environment:

```bash
# Find Alteon images
openstack image list | grep -i alteon

# Find available flavors
openstack flavor list

# Find external networks
openstack network list --external

# Check availability zones
openstack availability zone list

# List existing key pairs
openstack keypair list
```

### 4. Create SSH Key Pair (if needed)

```bash
# Option 1: Upload existing public key
openstack keypair create --public-key ~/.ssh/id_rsa.pub my-keypair

# Option 2: Generate new key pair
openstack keypair create my-keypair > my-keypair.pem
chmod 600 my-keypair.pem
```

### 5. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```

## 📊 Deployment Outputs

After successful deployment, Terraform provides:

```
alteon_mgmt_public_ip     = "203.0.113.10"     # Public management IP
alteon_mgmt_private_ip    = "10.0.1.10"        # Private management IP
alteon_data_private_ip    = "10.0.2.10"        # Data interface IP
alteon_servers_private_ip = "10.0.3.10"        # Servers interface IP
deployment_message        = "Access instructions..."
```

## 🔐 Access Your Alteon ADC

### Web Management Interface

- **Primary URL:** `https://<public-ip>`
- **Default Credentials:** 
  - Username: `admin`
  - Password: As configured in `admin_password` variable

### SSH Access

```bash
ssh -i your-keypair.pem -p 2222 admin@<public-ip>
```

### Important Notes

- 🕐 **Boot Time:** Allow 15-20 minutes for complete Alteon initialization
- 🔒 **Security:** Change default passwords immediately after deployment
- 🌐 **SSL:** The web interface uses self-signed certificates by default

## 📁 Project Structure

```
.
├── main.tf                 # Main Terraform configuration
├── variables.tf            # Variable definitions
├── terraform.tfvars.example # Example configuration
├── userdata.tpl           # Cloud-init template for Alteon
├── README.md              # This file
├── .gitignore             # Git ignore patterns
└── docs/                  # Additional documentation
    ├── TROUBLESHOOTING.md
    └── ADVANCED_CONFIG.md
```

## 🔧 Configuration Reference

### Network Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `subnet_cidrs` | CIDR blocks for the three networks | `["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]` |
| `adc_mgmt_private_ip` | Management interface IP | `"10.0.1.10"` |
| `adc_clients_private_ip` | Data/client interface IP | `"10.0.2.10"` |
| `adc_servers_private_ip` | Servers interface IP | `"10.0.3.10"` |

### Security Groups

The deployment creates three security groups:

1. **Management Security Group:**
   - SSH (22, 2222)
   - HTTPS (443, 8443)
   - Custom management (3121)
   - ICMP

2. **Data Security Group:**
   - All TCP ports (1-65535)
   - ICMP

3. **Servers Security Group:**
   - All TCP ports (1-65535)
   - ICMP

**⚠️ Production Warning:** The data and servers security groups allow all traffic for demonstration purposes. Restrict these rules in production environments.

## 🔍 Troubleshooting

### Common Issues

#### 1. Image Not Found
```
Error: No suitable image found for name: alteon-va
```
**Solution:** Check available images with `openstack image list | grep -i alteon`

#### 2. Flavor Not Available
```
Error: No suitable flavor found for name: m1.large
```
**Solution:** Check available flavors with `openstack flavor list`

#### 3. Network Already Exists
```
Error: A network with the name already exists
```
**Solution:** Use a different `deployment_id` or clean up existing resources

#### 4. IP Address Conflicts
```
Error: IP address 10.0.1.10 is already allocated
```
**Solution:** Check subnet allocation pools and use different IP addresses

#### 5. Quota Exceeded
```
Error: Quota exceeded for instances
```
**Solution:** Check quotas with `openstack quota show`

### Debugging Commands

```bash
# Check instance status
openstack server show alteon-instance-<deployment-id>

# View console output
openstack console log show alteon-instance-<deployment-id>

# Check floating IP association
openstack floating ip list

# Verify security group rules
openstack security group rule list alteon-mgmt-sg-<deployment-id>
```

## 🧹 Cleanup

To destroy all resources created by this deployment:

```bash
terraform destroy
```

**⚠️ Warning:** This action is irreversible and will delete all resources.

## 🔒 Security Best Practices

1. **Change Default Passwords:** Update `admin_password` from default values
2. **Restrict Security Groups:** Limit source IP ranges in production
3. **SSH Key Management:** Use secure SSH key pairs and rotate regularly
4. **Network Isolation:** Ensure proper network segmentation
5. **Regular Updates:** Keep Alteon images updated to latest versions
6. **Monitoring:** Implement proper logging and monitoring
7. **Backup Configuration:** Regularly backup Alteon configurations

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙋‍♂️ Support

For issues and questions:

- **Terraform OpenStack Provider:** [Provider Documentation](https://registry.terraform.io/providers/terraform-provider-openstack/openstack/latest/docs)
- **Alteon Documentation:** Contact Radware support
- **OpenStack Issues:** Consult your OpenStack cloud provider
- **Project Issues:** Create an issue in this repository

## 🏷️ Tags

`terraform` `openstack` `alteon` `adc` `load-balancer` `infrastructure-as-code` `networking` `cloud` `automation`

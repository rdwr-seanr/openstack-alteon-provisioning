terraform {
  required_version = ">= 0.14"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
  }
}

# Configure the OpenStack Provider
provider "openstack" {
  cloud = "openstack" # This will use the clouds.yaml file
}

# Get available flavors and images
data "openstack_compute_flavor_v2" "flavor" {
  name = var.instance_flavor
}

data "openstack_images_image_v2" "alteon_image" {
  name        = var.alteon_image_name
  most_recent = true
}

# Create management network
resource "openstack_networking_network_v2" "mgmt_network" {
  name           = "alteon-mgmt-network-${var.deployment_id}"
  admin_state_up = "true"

  tags = [
    "alteon",
    "management",
    var.deployment_id
  ]
}

# Create data network
resource "openstack_networking_network_v2" "data_network" {
  name           = "alteon-data-network-${var.deployment_id}"
  admin_state_up = "true"

  tags = [
    "alteon",
    "data",
    var.deployment_id
  ]
}

# Create servers network
resource "openstack_networking_network_v2" "servers_network" {
  name           = "alteon-servers-network-${var.deployment_id}"
  admin_state_up = "true"

  tags = [
    "alteon",
    "servers",
    var.deployment_id
  ]
}

# Create management subnet
resource "openstack_networking_subnet_v2" "mgmt_subnet" {
  name       = "alteon-mgmt-subnet-${var.deployment_id}"
  network_id = openstack_networking_network_v2.mgmt_network.id
  cidr       = var.subnet_cidrs[0]
  ip_version = 4

  allocation_pool {
    start = cidrhost(var.subnet_cidrs[0], 10)
    end   = cidrhost(var.subnet_cidrs[0], 250)
  }

  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# Create data subnet
resource "openstack_networking_subnet_v2" "data_subnet" {
  name       = "alteon-data-subnet-${var.deployment_id}"
  network_id = openstack_networking_network_v2.data_network.id
  cidr       = var.subnet_cidrs[1]
  ip_version = 4

  allocation_pool {
    start = cidrhost(var.subnet_cidrs[1], 10)
    end   = cidrhost(var.subnet_cidrs[1], 250)
  }

  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# Create servers subnet
resource "openstack_networking_subnet_v2" "servers_subnet" {
  name       = "alteon-servers-subnet-${var.deployment_id}"
  network_id = openstack_networking_network_v2.servers_network.id
  cidr       = var.subnet_cidrs[2]
  ip_version = 4

  allocation_pool {
    start = cidrhost(var.subnet_cidrs[2], 10)
    end   = cidrhost(var.subnet_cidrs[2], 250)
  }

  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

# Get external network for floating IP
data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

# Create router for external connectivity
resource "openstack_networking_router_v2" "alteon_router" {
  name                = "alteon-router-${var.deployment_id}"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id

  tags = [
    "alteon",
    var.deployment_id
  ]
}

# Attach management subnet to router
resource "openstack_networking_router_interface_v2" "mgmt_router_interface" {
  router_id = openstack_networking_router_v2.alteon_router.id
  subnet_id = openstack_networking_subnet_v2.mgmt_subnet.id
}

# Create security group for management
resource "openstack_networking_secgroup_v2" "mgmt_secgroup" {
  name        = "alteon-mgmt-sg-${var.deployment_id}"
  description = "Security group for Alteon management interface"

  tags = [
    "alteon",
    "management",
    var.deployment_id
  ]
}

# Security group rules for management
resource "openstack_networking_secgroup_rule_v2" "mgmt_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.mgmt_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_custom_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 2222
  port_range_max    = 2222
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.mgmt_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.mgmt_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_custom_https" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8443
  port_range_max    = 8443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.mgmt_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_custom_port" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 3121
  port_range_max    = 3121
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.mgmt_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "mgmt_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.mgmt_secgroup.id
}

# Create security group for data interface
resource "openstack_networking_secgroup_v2" "data_secgroup" {
  name        = "alteon-data-sg-${var.deployment_id}"
  description = "Security group for Alteon data interface"

  tags = [
    "alteon",
    "data",
    var.deployment_id
  ]
}

# Security group rules for data interface (allow all for simplicity)
resource "openstack_networking_secgroup_rule_v2" "data_all_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.data_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "data_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.data_secgroup.id
}

# Create security group for servers interface
resource "openstack_networking_secgroup_v2" "servers_secgroup" {
  name        = "alteon-servers-sg-${var.deployment_id}"
  description = "Security group for Alteon servers interface"

  tags = [
    "alteon",
    "servers",
    var.deployment_id
  ]
}

# Security group rules for servers interface (allow all for simplicity)
resource "openstack_networking_secgroup_rule_v2" "servers_all_tcp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.servers_secgroup.id
}

resource "openstack_networking_secgroup_rule_v2" "servers_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.servers_secgroup.id
}

# Create management port
resource "openstack_networking_port_v2" "mgmt_port" {
  name           = "alteon-mgmt-port-${var.deployment_id}"
  network_id     = openstack_networking_network_v2.mgmt_network.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.mgmt_subnet.id
    ip_address = var.adc_mgmt_private_ip
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.mgmt_secgroup.id
  ]
}

# Create data port
resource "openstack_networking_port_v2" "data_port" {
  name           = "alteon-data-port-${var.deployment_id}"
  network_id     = openstack_networking_network_v2.data_network.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.data_subnet.id
    ip_address = var.adc_clients_private_ip
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.data_secgroup.id
  ]
}

# Create servers port
resource "openstack_networking_port_v2" "servers_port" {
  name           = "alteon-servers-port-${var.deployment_id}"
  network_id     = openstack_networking_network_v2.servers_network.id
  admin_state_up = "true"

  fixed_ip {
    subnet_id  = openstack_networking_subnet_v2.servers_subnet.id
    ip_address = var.adc_servers_private_ip
  }

  security_group_ids = [
    openstack_networking_secgroup_v2.servers_secgroup.id
  ]
}

# Create floating IP for management access
resource "openstack_networking_floatingip_v2" "mgmt_fip" {
  pool = var.external_network_name

  tags = [
    "alteon",
    "management",
    var.deployment_id
  ]
}

# Associate floating IP with management port
resource "openstack_networking_floatingip_associate_v2" "mgmt_fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.mgmt_fip.address
  port_id     = openstack_networking_port_v2.mgmt_port.id
}

# Render the userdata template
data "template_file" "rendered_userdata" {
  template = file("${path.module}/userdata.tpl")

  vars = {
    admin_user                 = var.admin_user
    admin_password             = var.admin_password
    gel_enabled                = var.gel_enabled
    gel_url_primary            = var.gel_url_primary
    gel_url_secondary          = var.gel_url_secondary
    vm_name                    = var.vm_name
    gel_ent_id                 = var.gel_ent_id
    gel_throughput_mb          = var.gel_throughput_mb
    gel_dns_pri                = var.gel_dns_pri
    ntp_primary_server         = var.ntp_primary_server
    ntp_tzone                  = var.ntp_tzone
    cc_local_ip                = var.cc_local_ip
    cc_remote_ip               = var.cc_remote_ip
    adc_clients_private_ip     = var.adc_clients_private_ip
    adc_servers_private_ip     = var.adc_servers_private_ip
    adc_servers_private_ip_pip = var.adc_servers_private_ip_pip
    hst1_ip                    = var.hst1_ip
    hst1_severity              = var.hst1_severity
    hst1_facility              = var.hst1_facility
    hst1_module                = var.hst1_module
    hst1_port                  = var.hst1_port
    hst2_ip                    = var.hst2_ip
    hst2_severity              = var.hst2_severity
    hst2_facility              = var.hst2_facility
    hst2_module                = var.hst2_module
    hst2_port                  = var.hst2_port
  }
}

# Create Alteon instance
resource "openstack_compute_instance_v2" "alteon_instance" {
  name              = "alteon-instance-${var.deployment_id}"
  image_id          = data.openstack_images_image_v2.alteon_image.id
  flavor_id         = data.openstack_compute_flavor_v2.flavor.id
  key_pair          = var.key_pair_name
  availability_zone = var.availability_zone

  network {
    port = openstack_networking_port_v2.mgmt_port.id
  }

  network {
    port = openstack_networking_port_v2.data_port.id
  }

  network {
    port = openstack_networking_port_v2.servers_port.id
  }

  user_data = base64encode(data.template_file.rendered_userdata.rendered)

  metadata = {
    deployment_id = var.deployment_id
    role          = "alteon-adc"
  }

  tags = [
    "alteon",
    var.deployment_id
  ]

  lifecycle {
    ignore_changes = [
      user_data
    ]
  }
}

# Output important information
output "alteon_mgmt_private_ip" {
  description = "Private IP address of the management interface"
  value       = openstack_networking_port_v2.mgmt_port.all_fixed_ips[0]
}

output "alteon_mgmt_public_ip" {
  description = "Public IP address for management access"
  value       = openstack_networking_floatingip_v2.mgmt_fip.address
}

output "alteon_data_private_ip" {
  description = "Private IP address of the data interface"
  value       = openstack_networking_port_v2.data_port.all_fixed_ips[0]
}

output "alteon_servers_private_ip" {
  description = "Private IP address of the servers interface"
  value       = openstack_networking_port_v2.servers_port.all_fixed_ips[0]
}

output "deployment_message" {
  description = "Deployment information and access instructions"
  value = format(
    "Alteon ADC has been deployed to OpenStack with instance ID %s. Access it at https://%s. You can SSH into the instance using port 2222 with key %s. It might take 15-20 minutes for Alteon ADC to load up the config. Management IP: %s, Data IP: %s, Servers IP: %s, PIP: %s",
    openstack_compute_instance_v2.alteon_instance.id,
    openstack_networking_floatingip_v2.mgmt_fip.address,
    var.key_pair_name,
    openstack_networking_port_v2.mgmt_port.all_fixed_ips[0],
    openstack_networking_port_v2.data_port.all_fixed_ips[0],
    openstack_networking_port_v2.servers_port.all_fixed_ips[0],
    var.adc_servers_private_ip_pip
  )
}

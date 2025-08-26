# OpenStack provider variables
variable "external_network_name" {
  description = "Name of the external network for floating IPs"
  type        = string
  default     = "public"
}

variable "availability_zone" {
  description = "The OpenStack availability zone for deploying resources"
  type        = string
  default     = "nova"
}

variable "instance_flavor" {
  description = "OpenStack flavor name for the instance"
  type        = string
  default     = "m1.large"
}

variable "alteon_image_name" {
  description = "Name of the Alteon image in OpenStack"
  type        = string
  default     = "alteon-va"
}

variable "key_pair_name" {
  description = "Name of the OpenStack key pair for SSH access"
  type        = string
}

variable "deployment_id" {
  description = "Unique identifier for each deployment"
  type        = string
  default     = "default"
}

# Network variables
variable "subnet_cidrs" {
  description = "List of CIDR blocks for the subnets, should be /24"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "adc_mgmt_private_ip" {
  description = "Private IP for management interface"
  type        = string
  default     = "10.0.1.10"
}

variable "adc_clients_private_ip" {
  description = "Private IP for client side interface"
  type        = string
  default     = "10.0.2.10"
}

variable "adc_servers_private_ip" {
  description = "Private IP for server side interface"
  type        = string
  default     = "10.0.3.10"
}

variable "adc_servers_private_ip_pip" {
  description = "Proxy IP for server side"
  type        = string
  default     = "10.0.3.11"
}

# Alteon configuration variables
variable "admin_password" {
  description = "Admin password"
  type        = string
  default     = "radware123"
}

variable "admin_user" {
  description = "Admin username"
  type        = string
  default     = "admin"
}

variable "gel_enabled" {
  description = "Enable or disable GEL"
  type        = bool
  default     = false
}

variable "gel_url_primary" {
  description = "GEL primary URL"
  type        = string
  default     = "http://primary.gel.example.com"
}

variable "gel_url_secondary" {
  description = "GEL secondary URL"
  type        = string
  default     = "http://secondary.gel.example.com"
}

variable "gel_ent_id" {
  description = "GEL enterprise ID"
  type        = string
  default     = "12345"
}

variable "gel_throughput_mb" {
  description = "GEL throughput in MB"
  type        = string
  default     = "100"
}

variable "gel_dns_pri" {
  description = "GEL primary DNS"
  type        = string
  default     = "8.8.8.8"
}

variable "ntp_primary_server" {
  description = "NTP primary server IP Address only"
  type        = string
  default     = "132.163.97.8"
}

variable "ntp_tzone" {
  description = "NTP time zone"
  type        = string
  default     = "UTC"
}

variable "cc_local_ip" {
  description = "Local IP address"
  type        = string
  default     = "10.0.1.10"
}

variable "cc_remote_ip" {
  description = "Remote IP address"
  type        = string
  default     = "0.0.0.0"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "alteon-openstack-vm"
}

# Syslog configuration
variable "hst1_ip" {
  description = "Syslog Server IP for syslog host 1"
  type        = string
  default     = "1.2.3.4"
}

variable "hst1_severity" {
  description = "Severity[0-7] for syslog host 1"
  type        = string
  default     = "7"
}

variable "hst1_facility" {
  description = "Facility[0-7] for syslog host 1"
  type        = string
  default     = "0"
}

variable "hst1_module" {
  description = "Module for syslog host 1"
  type        = string
  default     = "all"
}

variable "hst1_port" {
  description = "Port for syslog host 1"
  type        = string
  default     = "514"
}

variable "hst2_ip" {
  description = "Syslog Server IP for syslog host 2"
  type        = string
  default     = "0.0.0.0"
}

variable "hst2_severity" {
  description = "Severity for syslog host 2"
  type        = string
  default     = "7"
}

variable "hst2_facility" {
  description = "Facility for syslog host 2"
  type        = string
  default     = "0"
}

variable "hst2_module" {
  description = "Module for syslog host 2"
  type        = string
  default     = "all"
}

variable "hst2_port" {
  description = "Port for syslog host 2"
  type        = string
  default     = "514"
}

# Helper variables
variable "operation" {
  description = "Operation type: create or destroy"
  type        = string
  default     = "create"
}

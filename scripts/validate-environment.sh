#!/bin/bash

# OpenStack Environment Validation Script
# This script helps validate your OpenStack environment before deploying Alteon ADC

set -e

echo "🔍 OpenStack Environment Validation for Alteon ADC Deployment"
echo "=============================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        return 1
    fi
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo
echo "📋 Checking Prerequisites..."

# Check Terraform
if command_exists terraform; then
    TERRAFORM_VERSION=$(terraform version | head -n1 | cut -d' ' -f2)
    print_status 0 "Terraform installed: $TERRAFORM_VERSION"
else
    print_status 1 "Terraform is not installed"
    echo "   Please install Terraform from: https://www.terraform.io/downloads.html"
    exit 1
fi

# Check OpenStack CLI
if command_exists openstack; then
    OPENSTACK_VERSION=$(openstack --version 2>&1 | cut -d' ' -f2)
    print_status 0 "OpenStack CLI installed: $OPENSTACK_VERSION"
else
    print_status 1 "OpenStack CLI is not installed"
    echo "   Please install with: pip install python-openstackclient"
    exit 1
fi

echo
echo "🔐 Checking OpenStack Authentication..."

# Test OpenStack connection
if openstack token issue >/dev/null 2>&1; then
    print_status 0 "OpenStack authentication successful"
    
    # Get project info
    PROJECT_NAME=$(openstack token issue -f value -c project_name 2>/dev/null || echo "Unknown")
    USER_NAME=$(openstack token issue -f value -c user_name 2>/dev/null || echo "Unknown")
    echo "   Project: $PROJECT_NAME"
    echo "   User: $USER_NAME"
else
    print_status 1 "OpenStack authentication failed"
    echo "   Please check your clouds.yaml file or environment variables"
    echo "   See docs/CLOUDS_YAML_EXAMPLE.md for configuration help"
    exit 1
fi

echo
echo "🔍 Checking OpenStack Resources..."

# Check images (look for Alteon)
echo "Available Alteon images:"
ALTEON_IMAGES=$(openstack image list -f value -c Name | grep -i alteon | head -5)
if [ -n "$ALTEON_IMAGES" ]; then
    while IFS= read -r image; do
        echo "   • $image"
    done <<< "$ALTEON_IMAGES"
    print_status 0 "Alteon images found"
else
    print_status 1 "No Alteon images found"
    echo "   Please upload an Alteon image to your OpenStack environment"
fi

# Check flavors
echo
echo "Available flavors with 4+ vCPUs:"
SUITABLE_FLAVORS=$(openstack flavor list -f value -c Name -c VCPUs -c RAM | awk '$2 >= 4 && $3 >= 8192 {print $1}' | head -5)
if [ -n "$SUITABLE_FLAVORS" ]; then
    while IFS= read -r flavor; do
        echo "   • $flavor"
    done <<< "$SUITABLE_FLAVORS"
    print_status 0 "Suitable flavors found"
else
    print_warning "No flavors with 4+ vCPUs and 8GB+ RAM found"
    echo "   Alteon ADC requires minimum 4 vCPU and 8GB RAM"
fi

# Check external networks
echo
echo "External networks:"
EXTERNAL_NETWORKS=$(openstack network list --external -f value -c Name)
if [ -n "$EXTERNAL_NETWORKS" ]; then
    while IFS= read -r network; do
        echo "   • $network"
    done <<< "$EXTERNAL_NETWORKS"
    print_status 0 "External networks found"
else
    print_status 1 "No external networks found"
    echo "   You need an external network for floating IP allocation"
fi

# Check quotas
echo
echo "📊 Checking Quotas..."
INSTANCES_QUOTA=$(openstack quota show -f value -c instances 2>/dev/null || echo "0")
INSTANCES_USED=$(openstack server list -f value | wc -l)
INSTANCES_AVAILABLE=$((INSTANCES_QUOTA - INSTANCES_USED))

if [ $INSTANCES_AVAILABLE -gt 0 ]; then
    print_status 0 "Instance quota: $INSTANCES_USED/$INSTANCES_QUOTA used"
else
    print_status 1 "Instance quota exceeded: $INSTANCES_USED/$INSTANCES_QUOTA"
fi

# Check networks quota
NETWORKS_QUOTA=$(openstack quota show -f value -c networks 2>/dev/null || echo "0")
NETWORKS_USED=$(openstack network list -f value | wc -l)
NETWORKS_AVAILABLE=$((NETWORKS_QUOTA - NETWORKS_USED))

if [ $NETWORKS_AVAILABLE -ge 3 ]; then
    print_status 0 "Network quota: $NETWORKS_USED/$NETWORKS_QUOTA used (need 3 for deployment)"
else
    print_warning "Network quota might be tight: $NETWORKS_USED/$NETWORKS_QUOTA (need 3 more)"
fi

echo
echo "🎯 Configuration Validation..."

# Check if terraform.tfvars exists
if [ -f "terraform.tfvars" ]; then
    print_status 0 "terraform.tfvars file exists"
    
    # Check key variables
    if grep -q "external_network_name" terraform.tfvars; then
        EXTERNAL_NET=$(grep "external_network_name" terraform.tfvars | cut -d'"' -f2)
        if echo "$EXTERNAL_NETWORKS" | grep -q "$EXTERNAL_NET"; then
            print_status 0 "External network '$EXTERNAL_NET' is valid"
        else
            print_status 1 "External network '$EXTERNAL_NET' not found"
        fi
    else
        print_warning "external_network_name not configured in terraform.tfvars"
    fi
    
    if grep -q "alteon_image_name" terraform.tfvars; then
        ALTEON_IMAGE=$(grep "alteon_image_name" terraform.tfvars | cut -d'"' -f2)
        if echo "$ALTEON_IMAGES" | grep -q "$ALTEON_IMAGE"; then
            print_status 0 "Alteon image '$ALTEON_IMAGE' is valid"
        else
            print_status 1 "Alteon image '$ALTEON_IMAGE' not found"
        fi
    else
        print_warning "alteon_image_name not configured in terraform.tfvars"
    fi
    
else
    print_status 1 "terraform.tfvars file not found"
    echo "   Please copy terraform.tfvars.example to terraform.tfvars and configure it"
fi

echo
echo "🎉 Validation Complete!"
echo
echo "Next steps:"
echo "1. Review any issues found above"
echo "2. Configure terraform.tfvars with your environment values"
echo "3. Run: terraform init"
echo "4. Run: terraform plan"
echo "5. Run: terraform apply"
echo
echo "For help, see docs/TROUBLESHOOTING.md"

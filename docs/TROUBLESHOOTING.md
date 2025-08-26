# Troubleshooting Guide

This guide helps you resolve common issues when deploying Alteon ADC on OpenStack using Terraform.

## 🔍 General Troubleshooting Steps

1. **Verify OpenStack connectivity:**
   ```bash
   openstack server list
   ```

2. **Check Terraform syntax:**
   ```bash
   terraform validate
   ```

3. **Review the plan before applying:**
   ```bash
   terraform plan
   ```

4. **Enable debug logging:**
   ```bash
   export TF_LOG=DEBUG
   terraform apply
   ```

## 🚫 Common Error Messages

### Authentication Errors

#### "Authentication failed"
```
Error: Error Creating OpenStack client: Invalid OpenStack credentials
```

**Solutions:**
- Verify your `clouds.yaml` configuration
- Check username, password, and project details
- Test with: `openstack token issue`
- Ensure proper file permissions: `chmod 600 ~/.config/openstack/clouds.yaml`

#### "Project not found"
```
Error: Project 'project-name' could not be found
```

**Solutions:**
- Verify project name in `clouds.yaml`
- Check if you have access to the project
- List available projects: `openstack project list`

### Resource Not Found Errors

#### "Image not found"
```
Error: No suitable image found for name: alteon-va
```

**Solutions:**
1. List available images:
   ```bash
   openstack image list | grep -i alteon
   ```
2. Update `alteon_image_name` in `terraform.tfvars`
3. Ensure the image is accessible to your project

#### "Flavor not available"
```
Error: No suitable flavor found for name: m1.large
```

**Solutions:**
1. List available flavors:
   ```bash
   openstack flavor list
   ```
2. Update `instance_flavor` in `terraform.tfvars`
3. Check flavor availability in your AZ

#### "External network not found"
```
Error: Unable to find network external
```

**Solutions:**
1. List external networks:
   ```bash
   openstack network list --external
   ```
2. Update `external_network_name` in `terraform.tfvars`

### Network and IP Issues

#### "IP address already allocated"
```
Error: IP address 10.0.1.10 is already allocated
```

**Solutions:**
1. Check subnet allocation pools:
   ```bash
   openstack subnet show <subnet-name>
   ```
2. Use different IP addresses in `terraform.tfvars`
3. Avoid x.x.x.1 (usually gateway)

#### "Network name conflict"
```
Error: A network with the name already exists
```

**Solutions:**
1. Use a different `deployment_id` value
2. Clean up existing resources:
   ```bash
   terraform destroy
   ```
3. Check for orphaned resources:
   ```bash
   openstack network list | grep alteon
   ```

### Quota and Resource Limits

#### "Quota exceeded"
```
Error: Quota exceeded for instances
```

**Solutions:**
1. Check current quotas:
   ```bash
   openstack quota show
   ```
2. Request quota increase from your admin
3. Clean up unused resources

#### "Insufficient resources"
```
Error: No valid host was found
```

**Solutions:**
1. Try a different availability zone
2. Use a smaller flavor
3. Check resource availability:
   ```bash
   openstack host list
   ```

### SSH Key Issues

#### "Key pair not found"
```
Error: Keypair 'my-keypair' was not found
```

**Solutions:**
1. List existing key pairs:
   ```bash
   openstack keypair list
   ```
2. Create a new key pair:
   ```bash
   openstack keypair create --public-key ~/.ssh/id_rsa.pub my-keypair
   ```
3. Update `key_pair_name` in `terraform.tfvars`

## 🔧 Instance-Specific Issues

### Instance Boot Problems

#### "Instance stuck in BUILD state"
```bash
# Check instance status
openstack server show alteon-instance-<deployment-id>

# Check console log
openstack console log show alteon-instance-<deployment-id>
```

**Common causes:**
- Insufficient resources
- Image compatibility issues
- Network configuration problems

#### "Cloud-init failed"
```bash
# Check cloud-init logs
openstack console log show alteon-instance-<deployment-id> | grep cloud-init
```

**Solutions:**
- Verify userdata template syntax
- Check if the image supports cloud-init
- Review variable substitution in `userdata.tpl`

### Network Connectivity Issues

#### "Cannot reach management interface"

**Debugging steps:**
1. Check floating IP association:
   ```bash
   openstack floating ip list
   ```

2. Verify security group rules:
   ```bash
   openstack security group rule list alteon-mgmt-sg-<deployment-id>
   ```

3. Test network connectivity:
   ```bash
   ping <floating-ip>
   telnet <floating-ip> 443
   ```

4. Check router and subnet configuration:
   ```bash
   openstack router show alteon-router-<deployment-id>
   ```

## 🐛 Terraform-Specific Issues

### State File Problems

#### "State lock error"
```
Error: Error locking state
```

**Solutions:**
1. Wait for other operations to complete
2. Force unlock (use with caution):
   ```bash
   terraform force-unlock <lock-id>
   ```

#### "Resource already exists"
```
Error: Resource already exists in state
```

**Solutions:**
1. Import existing resource:
   ```bash
   terraform import <resource_type>.<name> <resource_id>
   ```
2. Remove from state and recreate:
   ```bash
   terraform state rm <resource_type>.<name>
   ```

### Provider Issues

#### "Provider initialization failed"
```
Error: Failed to instantiate provider
```

**Solutions:**
1. Run `terraform init` again
2. Clear provider cache:
   ```bash
   rm -rf .terraform/
   terraform init
   ```

## 📊 Monitoring and Logging

### Enable Detailed Logging

```bash
# Terraform debug logging
export TF_LOG=DEBUG
export TF_LOG_PATH=./terraform.log

# OpenStack debug logging
export OS_DEBUG=1
```

### Useful Monitoring Commands

```bash
# Watch instance status
watch openstack server show alteon-instance-<deployment-id>

# Monitor resource usage
openstack limits show --absolute

# Check service status
openstack endpoint list
```

## 🔄 Recovery Procedures

### Partial Deployment Failure

1. **Check what was created:**
   ```bash
   terraform show
   ```

2. **Clean up and retry:**
   ```bash
   terraform destroy
   terraform apply
   ```

3. **Target specific resources:**
   ```bash
   terraform apply -target=resource_type.resource_name
   ```

### Complete Environment Reset

```bash
# Destroy everything
terraform destroy

# Clean up terraform state
rm -rf .terraform/
rm terraform.tfstate*

# Reinitialize
terraform init
terraform apply
```

## 📞 Getting Help

### Before Asking for Help

1. **Collect relevant information:**
   - Terraform version: `terraform version`
   - OpenStack CLI version: `openstack --version`
   - Error messages (full output)
   - Configuration files (without sensitive data)

2. **Try these debugging steps:**
   - Enable debug logging
   - Test OpenStack connectivity
   - Verify resource availability

3. **Check existing resources:**
   - GitHub issues
   - Terraform documentation
   - OpenStack documentation

### Where to Get Support

1. **Project Issues:** Create an issue with detailed information
2. **Terraform Provider:** Check OpenStack provider documentation
3. **OpenStack Support:** Contact your cloud provider
4. **Community Forums:** Stack Overflow, Reddit, Discord

## 🔧 Advanced Debugging

### Terraform Console

```bash
# Access terraform console for debugging
terraform console

# Example queries
> var.external_network_name
> data.openstack_networking_network_v2.external.id
```

### Resource Inspection

```bash
# Show detailed resource information
terraform state show openstack_compute_instance_v2.alteon_instance

# List all resources in state
terraform state list
```

### Manual Resource Management

```bash
# Create resources manually for testing
openstack network create test-network
openstack subnet create --network test-network --subnet-range 192.168.1.0/24 test-subnet

# Clean up manual resources
openstack subnet delete test-subnet
openstack network delete test-network
```

Remember: Most issues can be resolved by carefully reading error messages and following the suggested solutions. When in doubt, start with the basics: authentication, resource availability, and configuration validation.

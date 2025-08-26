# Example clouds.yaml Configuration

This file shows how to configure OpenStack authentication for use with this Terraform project.

## Location

Create this file at one of these locations:
- `~/.config/openstack/clouds.yaml` (Linux/macOS)
- `%APPDATA%\openstack\clouds.yaml` (Windows)

## Configuration Template

```yaml
clouds:
  openstack:
    auth:
      auth_url: https://your-openstack-endpoint:5000/v3
      username: "your-username"
      project_id: "your-project-id"
      project_name: "your-project-name"
      user_domain_name: "Default"
      project_domain_name: "Default"
      password: "your-password"
    region_name: "RegionOne"
    interface: "public"
    identity_api_version: 3
```

## Alternative: Environment Variables

Instead of using clouds.yaml, you can set these environment variables:

### Linux/macOS:
```bash
export OS_AUTH_URL=https://your-openstack-endpoint:5000/v3
export OS_USERNAME=your-username
export OS_PASSWORD=your-password
export OS_PROJECT_NAME=your-project-name
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_IDENTITY_API_VERSION=3
```

### Windows PowerShell:
```powershell
$env:OS_AUTH_URL="https://your-openstack-endpoint:5000/v3"
$env:OS_USERNAME="your-username"
$env:OS_PASSWORD="your-password"
$env:OS_PROJECT_NAME="your-project-name"
$env:OS_USER_DOMAIN_NAME="Default"
$env:OS_PROJECT_DOMAIN_NAME="Default"
$env:OS_IDENTITY_API_VERSION="3"
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Never commit clouds.yaml to version control**
2. **Set proper file permissions:**
   ```bash
   chmod 600 ~/.config/openstack/clouds.yaml
   ```
3. **Use application credentials when available** (more secure than passwords)
4. **Rotate passwords regularly**
5. **Use dedicated service accounts** for automation

## Testing Your Configuration

Test your OpenStack connection:

```bash
# List servers
openstack server list

# List images
openstack image list

# List networks
openstack network list

# Show current user info
openstack token issue
```

## Troubleshooting

### Common Issues:

1. **Authentication failed:**
   - Verify username and password
   - Check project name and domain names
   - Ensure auth_url is correct

2. **SSL certificate errors:**
   - Add `verify: false` to clouds.yaml (not recommended for production)
   - Or add the CA certificate to your system

3. **Permission denied:**
   - Check user has required roles in the project
   - Verify project quotas

## Multiple Clouds

You can configure multiple OpenStack clouds:

```yaml
clouds:
  production:
    auth:
      auth_url: https://prod-openstack:5000/v3
      username: "prod-user"
      # ... other settings
      
  development:
    auth:
      auth_url: https://dev-openstack:5000/v3
      username: "dev-user"
      # ... other settings
```

Then specify which cloud to use:
```bash
export OS_CLOUD=production
# or
openstack --os-cloud=development server list
```

## Application Credentials (Recommended)

For better security, use application credentials instead of passwords:

1. Create application credentials:
   ```bash
   openstack application credential create terraform-app
   ```

2. Use in clouds.yaml:
   ```yaml
   clouds:
     openstack:
       auth:
         auth_url: https://your-openstack-endpoint:5000/v3
         application_credential_id: "your-app-cred-id"
         application_credential_secret: "your-app-cred-secret"
   ```

This approach is more secure and doesn't require storing your user password.

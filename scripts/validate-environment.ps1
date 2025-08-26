# OpenStack Environment Validation Script for Windows
# This script helps validate your OpenStack environment before deploying Alteon ADC

Write-Host "🔍 OpenStack Environment Validation for Alteon ADC Deployment" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan

function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

function Write-Status {
    param($Success, $Message)
    if ($Success) {
        Write-Host "✅ $Message" -ForegroundColor Green
    } else {
        Write-Host "❌ $Message" -ForegroundColor Red
        return $false
    }
    return $true
}

function Write-Warning {
    param($Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 Checking Prerequisites..." -ForegroundColor White

# Check Terraform
if (Test-Command "terraform") {
    $TerraformVersion = (terraform version).Split("`n")[0]
    Write-Status $true "Terraform installed: $TerraformVersion"
} else {
    Write-Status $false "Terraform is not installed"
    Write-Host "   Please install Terraform from: https://www.terraform.io/downloads.html" -ForegroundColor Gray
    exit 1
}

# Check OpenStack CLI
if (Test-Command "openstack") {
    try {
        $OpenStackVersion = (openstack --version 2>&1).Split(" ")[1]
        Write-Status $true "OpenStack CLI installed: $OpenStackVersion"
    } catch {
        Write-Status $true "OpenStack CLI installed"
    }
} else {
    Write-Status $false "OpenStack CLI is not installed"
    Write-Host "   Please install with: pip install python-openstackclient" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "🔐 Checking OpenStack Authentication..." -ForegroundColor White

# Test OpenStack connection
try {
    $null = openstack token issue 2>$null
    Write-Status $true "OpenStack authentication successful"
    
    # Get project info
    try {
        $ProjectName = openstack token issue -f value -c project_name 2>$null
        $UserName = openstack token issue -f value -c user_name 2>$null
        Write-Host "   Project: $ProjectName" -ForegroundColor Gray
        Write-Host "   User: $UserName" -ForegroundColor Gray
    } catch {
        # Ignore if we can't get details
    }
} catch {
    Write-Status $false "OpenStack authentication failed"
    Write-Host "   Please check your clouds.yaml file or environment variables" -ForegroundColor Gray
    Write-Host "   See docs/CLOUDS_YAML_EXAMPLE.md for configuration help" -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "🔍 Checking OpenStack Resources..." -ForegroundColor White

# Check images (look for Alteon)
Write-Host "Available Alteon images:" -ForegroundColor White
try {
    $AlteonImages = openstack image list -f value -c Name | Select-String -Pattern "alteon" -CaseSensitive:$false | Select-Object -First 5
    if ($AlteonImages.Count -gt 0) {
        foreach ($image in $AlteonImages) {
            Write-Host "   • $image" -ForegroundColor Gray
        }
        Write-Status $true "Alteon images found"
    } else {
        Write-Status $false "No Alteon images found"
        Write-Host "   Please upload an Alteon image to your OpenStack environment" -ForegroundColor Gray
    }
} catch {
    Write-Warning "Could not check images"
}

# Check external networks
Write-Host ""
Write-Host "External networks:" -ForegroundColor White
try {
    $ExternalNetworks = openstack network list --external -f value -c Name
    if ($ExternalNetworks) {
        foreach ($network in $ExternalNetworks) {
            Write-Host "   • $network" -ForegroundColor Gray
        }
        Write-Status $true "External networks found"
    } else {
        Write-Status $false "No external networks found"
        Write-Host "   You need an external network for floating IP allocation" -ForegroundColor Gray
    }
} catch {
    Write-Warning "Could not check external networks"
}

Write-Host ""
Write-Host "🎯 Configuration Validation..." -ForegroundColor White

# Check if terraform.tfvars exists
if (Test-Path "terraform.tfvars") {
    Write-Status $true "terraform.tfvars file exists"
    
    $tfvarsContent = Get-Content "terraform.tfvars" -Raw
    
    # Check key variables
    if ($tfvarsContent -match 'external_network_name\s*=\s*"([^"]+)"') {
        $ExternalNet = $Matches[1]
        if ($ExternalNetworks -and ($ExternalNetworks -contains $ExternalNet)) {
            Write-Status $true "External network '$ExternalNet' is valid"
        } else {
            Write-Status $false "External network '$ExternalNet' not found"
        }
    } else {
        Write-Warning "external_network_name not configured in terraform.tfvars"
    }
    
    if ($tfvarsContent -match 'alteon_image_name\s*=\s*"([^"]+)"') {
        $AlteonImage = $Matches[1]
        if ($AlteonImages -and ($AlteonImages -match $AlteonImage)) {
            Write-Status $true "Alteon image '$AlteonImage' is valid"
        } else {
            Write-Status $false "Alteon image '$AlteonImage' not found"
        }
    } else {
        Write-Warning "alteon_image_name not configured in terraform.tfvars"
    }
} else {
    Write-Status $false "terraform.tfvars file not found"
    Write-Host "   Please copy terraform.tfvars.example to terraform.tfvars and configure it" -ForegroundColor Gray
}

Write-Host ""
Write-Host "🎉 Validation Complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "1. Review any issues found above" -ForegroundColor Gray
Write-Host "2. Configure terraform.tfvars with your environment values" -ForegroundColor Gray
Write-Host "3. Run: terraform init" -ForegroundColor Gray
Write-Host "4. Run: terraform plan" -ForegroundColor Gray
Write-Host "5. Run: terraform apply" -ForegroundColor Gray
Write-Host ""
Write-Host "For help, see docs/TROUBLESHOOTING.md" -ForegroundColor Gray

#Requires -Version 5.0
<#
.SYNOPSIS
    Deploy Windows VM with IIS using Terraform to Azure subscription.

.DESCRIPTION
    This script automates the Terraform deployment process:
    1. Authenticates to Azure
    2. Sets the target subscription
    3. Initializes Terraform
    4. Plans the deployment
    5. Applies the configuration
    6. Displays outputs

.PARAMETER SubscriptionId
    Azure subscription ID to deploy resources into.

.PARAMETER TerraformAction
    Action to perform: 'init', 'plan', 'apply', 'destroy', or 'all' (default: 'all')

.PARAMETER AutoApprove
    If specified, skips confirmation prompts for terraform apply.

.EXAMPLE
    # Deploy with user prompts
    .\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"

    # Deploy without prompts
    .\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -AutoApprove

    # Only plan the deployment
    .\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -TerraformAction "plan"

    # Destroy infrastructure
    .\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -TerraformAction "destroy" -AutoApprove

.NOTES
    Author: Vijay Nyalpelli
    Date: 28-May-2026
#>

param (
    [Parameter(Mandatory = $true, HelpMessage = "Azure subscription ID")]
    [ValidateScript({
        if ($_ -match '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') {
            $true
        } else {
            throw "Invalid subscription ID format. Please provide a valid UUID."
        }
    })]
    [string]$SubscriptionId,

    [Parameter(Mandatory = $false)]
    [ValidateSet('init', 'plan', 'apply', 'destroy', 'all')]
    [string]$TerraformAction = 'all',

    [switch]$AutoApprove
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Color output functions
function Write-Header {
    param([string]$Message)
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $Message -ForegroundColor Cyan
    Write-Host "========================================`n" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "? $Message" -ForegroundColor Green
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "? $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "? $Message" -ForegroundColor Red
}

try {
    Write-Header "Terraform Azure Deployment Script"

    # Check if Azure CLI is installed
    Write-Host "Checking prerequisites..."
    if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "Azure CLI is not installed. Please install it from https://docs.microsoft.com/cli/azure/"
        exit 1
    }
    Write-Success "Azure CLI found"

    if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
        Write-Error-Custom "Terraform is not installed. Please install it from https://www.terraform.io/downloads.html"
        exit 1
    }
    Write-Success "Terraform found"

    # Get Terraform version
    $tfVersion = terraform version -json | ConvertFrom-Json
    Write-Success "Terraform version: $($tfVersion.terraform_version)"

    # Check if terraform.tfvars exists
    if (-not (Test-Path "terraform.tfvars")) {
        Write-Warning-Custom "terraform.tfvars not found. Creating from terraform.tfvars.example..."
        if (Test-Path "terraform.tfvars.example") {
            Copy-Item "terraform.tfvars.example" "terraform.tfvars"
            Write-Success "terraform.tfvars created. Please edit it with your values."
        } else {
            Write-Error-Custom "terraform.tfvars.example not found!"
            exit 1
        }
    }

    # Update terraform.tfvars with subscription ID
    Write-Host "Updating terraform.tfvars with subscription ID..."
    $tfvarsContent = Get-Content "terraform.tfvars" -Raw
    $tfvarsContent = $tfvarsContent -replace 'subscription_id\s*=\s*"[^"]*"', "subscription_id = `"$SubscriptionId`""
    Set-Content "terraform.tfvars" -Value $tfvarsContent
    Write-Success "Subscription ID updated in terraform.tfvars"

    # Azure Login
    Write-Header "Azure Authentication"
    Write-Host "Checking Azure login status..."

    try {
        $currentAccount = az account show --query id -o tsv 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Already logged in to Azure"
            $currentSubscription = az account show --query name -o tsv
            Write-Host "Current subscription: $currentSubscription`n"
        } else {
            throw "Not authenticated"
        }
    } catch {
        Write-Host "Not logged in. Initiating Azure login..."
        az login
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Azure login failed!"
            exit 1
        }
    }

    # Set subscription
    Write-Header "Setting Azure Subscription"
    Write-Host "Setting subscription to: $SubscriptionId..."
    az account set --subscription $SubscriptionId
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to set subscription!"
        exit 1
    }

    $subscriptionName = az account show --query name -o tsv
    Write-Success "Subscription set to: $subscriptionName"

    # Terraform Init
    if ($TerraformAction -in @('init', 'all')) {
        Write-Header "Terraform Init"
        Write-Host "Initializing Terraform..."
        terraform init
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Terraform init failed!"
            exit 1
        }
        Write-Success "Terraform initialized successfully"
    }

    # Terraform Plan
    if ($TerraformAction -in @('plan', 'all')) {
        Write-Header "Terraform Plan"
        Write-Host "Planning Terraform deployment..."
        terraform plan -out=tfplan
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Terraform plan failed!"
            exit 1
        }
        Write-Success "Terraform plan completed successfully"
    }

    # Terraform Apply
    if ($TerraformAction -in @('apply', 'all')) {
        Write-Header "Terraform Apply"

        if (-not $AutoApprove) {
            $confirm = Read-Host "Do you want to apply these changes? (yes/no)"
            if ($confirm -ne 'yes') {
                Write-Host "Deployment cancelled." -ForegroundColor Yellow
                exit 0
            }
        }

        Write-Host "Applying Terraform configuration..."
        if (Test-Path "tfplan") {
            terraform apply -auto-approve tfplan
        } else {
            terraform apply -auto-approve
        }

        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Terraform apply failed!"
            exit 1
        }
        Write-Success "Terraform apply completed successfully"

        # Display outputs
        Write-Header "Deployment Outputs"
        terraform output
    }

    # Terraform Destroy
    if ($TerraformAction -eq 'destroy') {
        Write-Header "Terraform Destroy"
        Write-Warning-Custom "This will destroy all resources created by Terraform!"

        if (-not $AutoApprove) {
            $confirm = Read-Host "Type 'destroy' to confirm resource destruction"
            if ($confirm -ne 'destroy') {
                Write-Host "Destruction cancelled." -ForegroundColor Yellow
                exit 0
            }
        }

        Write-Host "Destroying Terraform resources..."
        terraform destroy -auto-approve
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "Terraform destroy failed!"
            exit 1
        }
        Write-Success "All resources destroyed successfully"
    }

    Write-Header "Deployment Complete"
    Write-Success "Terraform deployment script finished successfully!"

} catch {
    Write-Error-Custom "An error occurred: $_"
    exit 1
}

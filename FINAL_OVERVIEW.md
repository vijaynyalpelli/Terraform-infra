# Repository Complete Setup Overview

## ?? Repository Structure

```
terraform-infra/
??? ?? Terraform Configuration
?   ??? providers.tf               ? Updated (uses var.subscription_id)
?   ??? variables.tf               ? Updated (added subscription_id variable)
?   ??? main.tf                    ? Ready (VM, Network, IIS provisioning)
?   ??? outputs.tf                 ? Ready (IP, VM name, username)
?   ??? terraform.tfvars.example   ? Updated (includes subscription_id placeholder)
?
??? ?? Deployment Scripts
?   ??? deploy.ps1                 ? NEW - PowerShell automation script
?   ??? scripts/
?       ??? install-iis.ps1        ? PowerShell IIS installation script
?
??? ?? Documentation
?   ??? README.md                  ? Project overview
?   ??? QUICKSTART.md              ? 5-minute setup guide
?   ??? DEPLOYMENT_GUIDE.md        ? Detailed instructions
?   ??? SUBSCRIPTION_ID_SETUP.md   ? Technical reference
?   ??? SETUP_CHECKLIST.md         ? Pre-flight checklist
?
??? ?? Configuration
    ??? .gitignore                 ? Protects secrets

??  terraform.tfvars              ??  USER MUST CREATE (copy from .example)
```

---

## ?? Files Updated for Subscription ID Support

### 1. **providers.tf** ? UPDATED
**What:** Provider configuration for Azure
```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id  # Now uses variable!
}
```

### 2. **variables.tf** ? UPDATED  
**What:** Added subscription_id input variable
```hcl
variable "subscription_id" {
  description = "Azure subscription ID to deploy resources into."
  type        = string
}
```

### 3. **terraform.tfvars.example** ? UPDATED
**What:** Example configuration with placeholder
```hcl
subscription_id = "YOUR-SUBSCRIPTION-ID"
```

---

## ?? How to Deploy in 3 Steps

### Step 1??: Get Subscription ID
```powershell
az login
az account list --output table
```
?? Note down the ID you want to use

---

### Step 2??: Create terraform.tfvars
```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
notepad terraform.tfvars
```

Edit these values:
```hcl
subscription_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # Your actual ID
admin_password  = "YourSecurePassword123!"                # Strong password
```

? **Never commit this file** - it's in .gitignore

---

### Step 3??: Run Deployment
```powershell
# Allow script execution (first-time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Deploy with your subscription ID
.\deploy.ps1 -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -AutoApprove
```

?? **Done!** Wait for completion and note the IP address

---

## ?? deploy.ps1 Features

The PowerShell deployment script does:

? Checks prerequisites (Azure CLI, Terraform)  
? Validates subscription ID format  
? Authenticates to Azure automatically  
? Sets the target subscription  
? Updates terraform.tfvars with subscription ID  
? Runs terraform init ? plan ? apply  
? Displays results with colored output  
? Shows error messages clearly  
? Handles confirmations intelligently  
? Supports destroy action  

### Parameters

```powershell
.\deploy.ps1 -SubscriptionId <ID> [-TerraformAction <action>] [-AutoApprove]

# Examples:
.\deploy.ps1 -SubscriptionId "xxx" -AutoApprove                    # Full deploy
.\deploy.ps1 -SubscriptionId "xxx" -TerraformAction "plan"          # Preview only
.\deploy.ps1 -SubscriptionId "xxx" -TerraformAction "destroy" -AutoApprove  # Cleanup
```

---

## ?? Documentation Files

| File | Purpose | When to Use |
|------|---------|------------|
| **QUICKSTART.md** | 5-minute guide | First time, just want to deploy |
| **DEPLOYMENT_GUIDE.md** | Step-by-step with examples | Detailed instructions & troubleshooting |
| **SUBSCRIPTION_ID_SETUP.md** | Technical reference | Understanding the setup |
| **SETUP_CHECKLIST.md** | Pre-flight checklist | Make sure everything is ready |
| **README.md** | Project overview | Project description & contents |

---

## ?? Subscription ID Everywhere?

### ? Not Hardcoded Anymore
Before:
```hcl
# Hardcoded in provider
provider "azurerm" {
  subscription_id = "YOUR-SUBSCRIPTION-ID-HERE"
}
```

### ? Now It's Dynamic
```hcl
# Variable in variables.tf
variable "subscription_id" {
  type = string
}

# Used in provider
provider "azurerm" {
  subscription_id = var.subscription_id
}

# Set in terraform.tfvars (per user)
subscription_id = "YOUR-ACTUAL-ID"
```

### Benefits:
- ? Each user has their own configuration
- ? Easy to switch subscriptions
- ? Secrets not in code repository
- ? CI/CD friendly
- ? Multiple environments possible

---

## ??? Security Features

| Feature | Implementation |
|---------|-----------------|
| **Secrets Protection** | `.gitignore` prevents terraform.tfvars commit |
| **Sensitive Values** | admin_password marked as sensitive |
| **No Hardcoding** | subscription_id is a variable |
| **State Files** | .tfstate files ignored |
| **Local Cache** | .terraform directory ignored |

? **All production-ready**

---

## ? Pre-Deployment Checklist

Before running `.\deploy.ps1`:

- [ ] Azure CLI installed (`az --version`)
- [ ] Terraform installed (`terraform --version`)
- [ ] Azure login works (`az login`)
- [ ] Subscription ID obtained (`az account list`)
- [ ] terraform.tfvars created (copy from .example)
- [ ] subscription_id updated in terraform.tfvars
- [ ] admin_password set to strong value
- [ ] PowerShell execution policy allows scripts
- [ ] You own the subscription (have permissions)

---

## ?? What Gets Deployed

? **Resource Group** - Container for all resources  
? **Virtual Network** - 10.0.0.0/16 network  
? **Subnet** - 10.0.1.0/24 network segment  
? **Public IP** - Internet-facing IP address  
? **Network Interface** - VM's network adapter  
? **Windows VM** - Server 2019 Datacenter  
? **IIS** - Web server with sample site  

All in your specified Azure subscription.

---

## ?? After Deployment

The script will output:

```
Outputs:

admin_username = "azureuser"
public_ip_address = "13.67.123.45"
vm_name = "win-iis-vm"
```

### Access Options:

**Via Web Browser:**
```
http://13.67.123.45
```
(Shows sample IIS page)

**Via Remote Desktop:**
```
Host: 13.67.123.45
Username: azureuser
Password: (from terraform.tfvars)
Port: 3389
```

---

## ??? Cleanup (Delete Everything)

When done testing:

```powershell
.\deploy.ps1 -SubscriptionId "xxx" -TerraformAction "destroy" -AutoApprove
```

Or manually:

```powershell
terraform destroy -auto-approve
```

?? **This deletes all deployed resources permanently**

---

## ? Quick Commands Reference

```powershell
# Initial setup
az login
Copy-Item terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your ID and password

# Deploy
.\deploy.ps1 -SubscriptionId "YOUR-ID" -AutoApprove

# Just preview (don't deploy)
.\deploy.ps1 -SubscriptionId "YOUR-ID" -TerraformAction "plan"

# Manual deployment (no script)
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# Get outputs again
terraform output

# Cleanup
terraform destroy -auto-approve
```

---

## ?? Troubleshooting

### Error: Cannot find 'az' command
```powershell
# Install Azure CLI
# https://docs.microsoft.com/cli/azure/install-azure-cli-windows
```

### Error: Cannot find 'terraform' command
```powershell
# Install Terraform
# https://www.terraform.io/downloads.html
```

### Error: Scripts disabled
```powershell
# Allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: Invalid subscription ID
```powershell
# List and copy correct ID
az account list --output table
```

### Error: Password doesn't meet Azure requirements
- Minimum 8 characters
- Include uppercase (A-Z)
- Include lowercase (a-z)
- Include number (0-9)
- Include special character (!@#$%^&*)

Example: `P@ssw0rd123!`

---

## ?? Files Status Summary

| File | Type | Status | Action |
|------|------|--------|--------|
| providers.tf | Modified | ? Ready | None |
| variables.tf | Modified | ? Ready | None |
| main.tf | Existing | ? Ready | None |
| outputs.tf | Existing | ? Ready | None |
| terraform.tfvars.example | Modified | ? Ready | None |
| **terraform.tfvars** | **New** | **?? CREATE** | Copy from .example |
| deploy.ps1 | New | ? Ready | Run it |
| scripts/install-iis.ps1 | Existing | ? Ready | None |
| .gitignore | New | ? Ready | None |
| Documentation | New | ? Ready | Reference |

---

## ?? Next Steps

1. **First Time?** ? Read `QUICKSTART.md`
2. **Need Details?** ? Read `DEPLOYMENT_GUIDE.md`  
3. **Want to Understand?** ? Read `SUBSCRIPTION_ID_SETUP.md`
4. **Ready to Deploy?** ? Follow the 3-step process above
5. **After Deploy?** ? Check outputs and access your IIS site
6. **Done Testing?** ? Run `terraform destroy` to cleanup

---

## ? Repository Ready!

? All files configured  
? Subscription ID support added  
? PowerShell automation script included  
? Security best practices implemented  
? Comprehensive documentation provided  

**You're ready to deploy Windows VM + IIS to Azure!**

---

**Last Updated:** 2026-05-27  
**Status:** ? Production Ready

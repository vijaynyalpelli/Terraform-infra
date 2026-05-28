# Setup Checklist ?

## Files Updated for Subscription ID Support

### 1. ? variables.tf
- Added `subscription_id` variable at the top
- Type: string (required, no default)
- Other variables remain unchanged

**Status:** READY - No action needed

---

### 2. ? providers.tf  
- Changed `subscription_id = "YOUR-SUBSCRIPTION-ID-HERE"`
- Now uses: `subscription_id = var.subscription_id`
- Terraform block properly closed

**Status:** READY - No action needed

---

### 3. ? terraform.tfvars.example
- Added line: `subscription_id = "YOUR-SUBSCRIPTION-ID"`
- Copy this file to `terraform.tfvars` and update with actual ID

**Status:** READY - User must copy to terraform.tfvars

---

### 4. ? deploy.ps1 (NEW)
- Automated PowerShell deployment script
- Features:
  - ? Prerequisite checking (Azure CLI, Terraform)
  - ? Azure authentication
  - ? Subscription selection
  - ? Auto-updates terraform.tfvars with subscription ID
  - ? terraform init ? plan ? apply automation
  - ? Colored console output
  - ? Error handling
  - ? Parameter validation

**Status:** READY - Use with `-SubscriptionId` parameter

---

### 5. ? .gitignore (NEW)
- Protects sensitive files from Git
- Includes:
  - terraform.tfvars (secrets)
  - .terraform/ (local cache)
  - terraform.tfstate* (state files)
  - Logs and temp files

**Status:** READY - Already in place

---

### 6. ? DEPLOYMENT_GUIDE.md (NEW)
- Complete step-by-step instructions
- Multiple example commands
- Troubleshooting section
- Security best practices
- Environment variable alternatives
- Manual commands reference

**Status:** READY - Reference documentation

---

### 7. ? SUBSCRIPTION_ID_SETUP.md (NEW)
- Technical reference
- Files-by-file explanation
- Security notes
- Alternative methods

**Status:** READY - Reference documentation

---

### 8. ? QUICKSTART.md (NEW)
- 5-minute quick start guide
- Minimal steps
- Quick troubleshooting

**Status:** READY - For fast deployment

---

## How to Use - Step by Step

### Step 1: Prepare Azure
```powershell
# Get your subscription ID
az login
az account list --output table

# Note: Save the ID (format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
```

### Step 2: Create Configuration File
```powershell
# Copy example to actual config
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` (opens in default editor):
```powershell
# Edit with notepad or your editor
notepad terraform.tfvars
```

Update these lines:
```hcl
subscription_id = "YOUR-SUBSCRIPTION-ID"     # Paste your ID here
admin_password  = "YourSecurePassword123!"   # Use strong password
```

### Step 3: Run PowerShell Script
```powershell
# Allow script execution (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Run deployment with your subscription ID
.\deploy.ps1 -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -AutoApprove
```

### Step 4: Wait for Completion
Script will:
1. ? Check prerequisites
2. ? Authenticate to Azure
3. ? Set subscription
4. ? Initialize Terraform
5. ? Plan deployment
6. ? Apply configuration
7. ? Show output (IP address, username)

---

## What Gets Deployed

- ? Azure Resource Group
- ? Virtual Network (10.0.0.0/16)
- ? Subnet (10.0.1.0/24)
- ? Public IP Address
- ? Network Interface
- ? Windows Server 2019 Datacenter VM
  - Size: Standard_B2s
  - Admin: azureuser
- ? IIS (Internet Information Services)
  - Sample website deployed
  - Accessible via HTTP

---

## After Deployment

Terraform output will show:
```
Outputs:

admin_username = "azureuser"
public_ip_address = "13.67.123.45"
vm_name = "win-iis-vm"
```

### Access the VM

#### Via Browser (HTTP)
- URL: `http://13.67.123.45` (use your actual IP)
- Shows: Sample IIS page deployed by Terraform

#### Via Remote Desktop (RDP)
- Host: `13.67.123.45`
- Username: `azureuser`
- Password: (from terraform.tfvars)
- Port: 3389 (default)

---

## Files Status

| File | Type | Status | User Action |
|------|------|--------|-------------|
| variables.tf | Modified | ? Ready | None - already updated |
| providers.tf | Modified | ? Ready | None - already updated |
| main.tf | Existing | ? Ready | None - no changes needed |
| outputs.tf | Existing | ? Ready | None - no changes needed |
| terraform.tfvars.example | Modified | ? Ready | Reference only |
| terraform.tfvars | To Create | ? Action Needed | **MUST CREATE** from .example |
| deploy.ps1 | New | ? Ready | Run this script |
| .gitignore | New | ? Ready | Already in place |
| DEPLOYMENT_GUIDE.md | New | ? Ready | Reference |
| SUBSCRIPTION_ID_SETUP.md | New | ? Ready | Reference |
| QUICKSTART.md | New | ? Ready | Reference |

---

## Commands Quick Reference

### First Time Setup
```powershell
# Copy configuration
Copy-Item terraform.tfvars.example terraform.tfvars

# Edit configuration
notepad terraform.tfvars

# Allow scripts to run (one-time)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### Deploy
```powershell
# Full deployment with prompts
.\deploy.ps1 -SubscriptionId "YOUR-ID"

# Full deployment without prompts
.\deploy.ps1 -SubscriptionId "YOUR-ID" -AutoApprove

# Only plan (preview)
.\deploy.ps1 -SubscriptionId "YOUR-ID" -TerraformAction "plan"

# Only apply
.\deploy.ps1 -SubscriptionId "YOUR-ID" -TerraformAction "apply" -AutoApprove
```

### Manual (without script)
```powershell
# Authenticate
az login
az account set --subscription "YOUR-ID"

# Deploy
terraform init
terraform plan -out=tfplan
terraform apply tfplan

# View outputs
terraform output
```

### Cleanup
```powershell
# With script
.\deploy.ps1 -SubscriptionId "YOUR-ID" -TerraformAction "destroy" -AutoApprove

# Manual
terraform destroy -auto-approve
```

---

## Troubleshooting Checklist

- [ ] Have you installed Azure CLI? ? Download from https://docs.microsoft.com/cli/azure/
- [ ] Have you installed Terraform? ? Download from https://www.terraform.io/
- [ ] Are you logged into Azure? ? Run `az login`
- [ ] Is your subscription ID in correct format? ? Should be `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`
- [ ] Have you created terraform.tfvars? ? Copy from .example first
- [ ] Is your password strong enough? ? Must have uppercase, lowercase, number, special char
- [ ] Can you run PowerShell scripts? ? May need to adjust execution policy
- [ ] Is the subscription ID in terraform.tfvars? ? Check first line of file
- [ ] Is .gitignore preventing secret commits? ? Already added ?

---

## Important Security Reminders

?? **DO NOT:**
- Commit `terraform.tfvars` to Git (contains password)
- Share your subscription ID publicly
- Use simple passwords
- Store state files in public locations
- Push `.terraform/` directory to Git

? **DO:**
- Use strong passwords with special characters
- Keep `terraform.tfvars` in `.gitignore`
- Review deployed resources
- Run `terraform destroy` when done testing
- Use Azure Key Vault for production

---

## Next Steps (Optional)

1. **Add Network Security Group** - Restrict RDP/HTTP access
2. **Use Azure Key Vault** - Store password securely
3. **Add Azure Monitor** - Monitor VM performance
4. **Enable Disk Encryption** - Encrypt OS disk
5. **Add Backup** - Backup VM configuration
6. **Add Tags** - Track costs and resources

See documentation files for examples.

---

## Getting Help

### Documentation Files
- `QUICKSTART.md` - Fast 5-minute guide
- `DEPLOYMENT_GUIDE.md` - Detailed instructions
- `SUBSCRIPTION_ID_SETUP.md` - Technical reference
- `README.md` - Project overview

### Azure Resources
- Azure Documentation: https://docs.microsoft.com/azure/
- Azure CLI: https://docs.microsoft.com/cli/azure/
- Azure VM SKUs: https://docs.microsoft.com/azure/virtual-machines/

### Terraform Resources
- Terraform Docs: https://www.terraform.io/docs/
- AzureRM Provider: https://registry.terraform.io/providers/hashicorp/azurerm/

---

**Status: ? ALL SYSTEMS READY FOR DEPLOYMENT**

You can now proceed with the 3-step setup process above.

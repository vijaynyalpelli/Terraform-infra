# PowerShell Deployment Guide

## Quick Setup

### Step 1: Get Your Azure Subscription ID

```powershell
# List all subscriptions
az account list --output table

# Or get current subscription ID
az account show --query id -o tsv
```

### Step 2: Update terraform.tfvars

Copy `terraform.tfvars.example` to `terraform.tfvars`:

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Then edit `terraform.tfvars` and update:
- `subscription_id` = "YOUR-SUBSCRIPTION-ID-HERE"
- `admin_password` = "YourSecurePassword!" (minimum 8 chars, uppercase, lowercase, number, special char)
- Other variables as needed

### Step 3: Run Deployment Script

#### Option 1: Full Deployment (init ? plan ? apply)
```powershell
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012"
```

#### Option 2: Full Deployment Without Prompts
```powershell
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -AutoApprove
```

#### Option 3: Only Plan (Preview Changes)
```powershell
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -TerraformAction "plan"
```

#### Option 4: Destroy Resources
```powershell
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -TerraformAction "destroy" -AutoApprove
```

---

## Manual Terraform Commands

If you prefer to run Terraform manually:

### Login to Azure
```powershell
az login
az account set --subscription "YOUR-SUBSCRIPTION-ID"
```

### Initialize Terraform
```powershell
terraform init
```

### Preview Changes
```powershell
terraform plan -out=tfplan
```

### Apply Configuration
```powershell
terraform apply tfplan
```

### Get Outputs
```powershell
terraform output
terraform output public_ip_address
```

### Destroy Resources
```powershell
terraform destroy
```

---

## Files That Require Subscription ID

### 1. **variables.tf** (? Updated)
- Added `subscription_id` variable declaration
- No changes needed by user

### 2. **providers.tf** (? Updated)
- Changed from hardcoded subscription to use `var.subscription_id`
- No changes needed by user

### 3. **terraform.tfvars.example** (? Updated)
- Added placeholder: `subscription_id = "YOUR-SUBSCRIPTION-ID"`
- User must copy to `terraform.tfvars` and update with actual ID

### 4. **terraform.tfvars** (To be created by user)
- User must create this from `.example` file
- **Do NOT commit this to Git** (contains sensitive data)
- **Add to .gitignore:**
  ```
  terraform.tfvars
  .terraform/
  terraform.tfstate*
  tfplan
  ```

---

## Troubleshooting

### Issue: "Azure CLI is not installed"
**Solution:** Download from https://docs.microsoft.com/cli/azure/install-azure-cli-windows

### Issue: "Terraform is not installed"
**Solution:** Download from https://www.terraform.io/downloads.html

### Issue: "Invalid subscription ID"
**Solution:** Verify format: `12345678-1234-1234-1234-123456789012`
Run `az account list --output table` to find correct ID

### Issue: "Authentication failed"
**Solution:** Run `az login` to re-authenticate with Azure

### Issue: "Password does not meet requirements"
**Solution:** Windows requires passwords with:
- Minimum 8 characters
- At least 1 uppercase letter
- At least 1 lowercase letter
- At least 1 number
- At least 1 special character (!@#$%^&*)

Example: `P@ssw0rd123!`

---

## Environment Variables (Alternative Method)

If you prefer environment variables instead of editing `terraform.tfvars`:

```powershell
$env:TF_VAR_subscription_id = "12345678-1234-1234-1234-123456789012"
$env:TF_VAR_admin_password = "P@ssw0rd123!"
$env:TF_VAR_location = "eastus"

terraform init
terraform plan
terraform apply -auto-approve
```

---

## After Successful Deployment

Once deployment completes, you'll see outputs:

```
Outputs:

admin_username = "azureuser"
public_ip_address = "13.67.123.45"
vm_name = "win-iis-vm"
```

### Access Your IIS Server:
1. Open browser and navigate to: `http://13.67.123.45` (use your actual IP)
2. Or connect via RDP:
   - Address: `13.67.123.45`
   - Username: `azureuser`
   - Password: (the one from terraform.tfvars)

---

## Security Best Practices

1. **Never commit secrets to Git**
   - Add `terraform.tfvars` to `.gitignore`
   - Never share subscription IDs or passwords publicly

2. **Use Azure Key Vault for production**
   - Store passwords in Key Vault instead of `terraform.tfvars`
   - Reference via data source in `main.tf`

3. **Enable MFA on your Azure account**
   - Run `az account set --subscription "..." --auth-mode interactive`

4. **Use managed identities when possible**
   - Avoid storing credentials in files

5. **Regularly run `terraform destroy`**
   - Delete test resources after use to avoid unnecessary costs

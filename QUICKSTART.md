# Quick Start - 5 Minutes

## 1. Get Subscription ID (1 min)
```powershell
az login
az account list --output table
# Copy the ID for your target subscription
```

## 2. Create terraform.tfvars (2 min)
```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and update these two lines:
```hcl
subscription_id = "YOUR-SUBSCRIPTION-ID-HERE"    # Replace with your actual ID
admin_password  = "YourSecurePassword123!"        # Must have uppercase, lowercase, numbers, special chars
```

## 3. Run Deployment (2 min)
```powershell
# Allow script execution (first time only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Deploy
.\deploy.ps1 -SubscriptionId "YOUR-SUBSCRIPTION-ID" -AutoApprove
```

---

## That's It! 

After the script completes, you'll see:
- ? Resource group created
- ? Virtual network created  
- ? Windows VM created
- ? IIS installed automatically
- ? Public IP assigned

Outputs will show:
```
public_ip_address = "your.ip.address.here"
vm_name = "win-iis-vm"
admin_username = "azureuser"
```

## Access Your IIS Server
Open browser: `http://your.ip.address.here`

---

## To Cleanup (Delete Everything)
```powershell
.\deploy.ps1 -SubscriptionId "YOUR-SUBSCRIPTION-ID" -TerraformAction "destroy" -AutoApprove
```

---

## Troubleshooting

| Error | Solution |
|-------|----------|
| "Cannot find az command" | Install Azure CLI: https://docs.microsoft.com/cli/azure/install-azure-cli-windows |
| "Cannot find terraform" | Install Terraform: https://www.terraform.io/downloads.html |
| "Running scripts disabled" | Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| "Invalid subscription ID" | Run `az account list --output table` and use the correct ID |
| "Password requirement error" | Password must have: uppercase, lowercase, number, special char (!@#$%^&*) |
| "Resource group already exists" | Change `resource_group_name` in `terraform.tfvars` |

---

## Files to Know About

| File | Purpose |
|------|---------|
| `terraform.tfvars` | **YOU MUST CREATE THIS** - Your configuration with actual subscription ID |
| `deploy.ps1` | PowerShell script to automate deployment |
| `DEPLOYMENT_GUIDE.md` | Detailed instructions and examples |
| `SUBSCRIPTION_ID_SETUP.md` | Complete technical reference |

---

## Never Commit These to Git

```
? terraform.tfvars         (contains your subscription ID & password)
? .terraform/              (local Terraform cache)
? terraform.tfstate*       (state files with sensitive data)
```

These are already in `.gitignore` ?

---

## Next Steps (Optional Enhancements)

- Add Network Security Group (NSG) to restrict ports
- Store password in Azure Key Vault
- Add tags for cost tracking
- Enable auto-shutdown to save costs
- Add monitoring and alerts

See `DEPLOYMENT_GUIDE.md` for more options.

# Secure Deployment Guide - Subscription ID Management

## Overview

This repository is configured to **NEVER commit the subscription ID or other secrets** to Git. All sensitive values are:
- ? Provided at runtime (via script parameters or environment variables)
- ? Excluded from Git via `.gitignore`
- ? Never stored in committed files

---

## How to Deploy

### **Method 1: Using deploy.ps1 (Recommended)**

This is the recommended method. The script accepts the subscription ID as a parameter and writes it into `terraform.tfvars` on disk (created from `terraform.tfvars.example`) so Terraform can read it. The `terraform.tfvars` file is listed in `.gitignore` and should not be committed.

#### Command:
```powershell
.\deploy.ps1 -SubscriptionId "YOUR-SUBSCRIPTION-ID"
```

#### Examples:
```powershell
# Full deployment with prompts
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc"

# Full deployment without prompts
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -AutoApprove

# Only plan (preview) without applying
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -TerraformAction "plan"

# Destroy infrastructure
.\deploy.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789abc" -TerraformAction "destroy" -AutoApprove
```

**How it works:**
1. Script receives subscription ID as parameter
2. The script creates/updates `terraform.tfvars` from `terraform.tfvars.example` and inserts the provided subscription ID.
3. Terraform uses the values from `terraform.tfvars` for deployment.
4. `terraform.tfvars` is ignored by Git (see `.gitignore`) — do not commit it.

---

### **Method 2: Manual Environment Variables**

Set subscription ID as an environment variable (never stored in files):

#### PowerShell:
```powershell
# Set environment variable
$env:TF_VAR_subscription_id = "12345678-1234-1234-1234-123456789abc"

# Run Terraform
terraform init
terraform plan
terraform apply
```

#### Command Prompt:
```cmd
set TF_VAR_subscription_id=12345678-1234-1234-1234-123456789abc
terraform apply
```

---

### **Method 3: Edit terraform.tfvars Locally (For Testing Only)**

If you need to edit locally for testing:

```powershell
# Edit terraform.tfvars with your subscription ID
notepad terraform.tfvars
```

**?? IMPORTANT:**
- `.gitignore` prevents accidental commits
- Verify before any `git push`:
  ```powershell
  git status
  # Should show: "nothing to commit" or only untracked files
  ```
- Never `git add terraform.tfvars`

---

## Files and Their Purpose

| File | Contains Secrets? | Committed to Git? | Purpose |
|------|-------------------|-------------------|---------|
| `variables.tf` | ? No | ? Yes | Variable declarations (types, descriptions) |
| `providers.tf` | ? No | ? Yes | Provider configuration |
| `main.tf` | ? No | ? Yes | Infrastructure resources |
| `terraform.tfvars.example` | ? No | ? Yes | Example/template (placeholder values) |
| `terraform.tfvars` | ?? Yes (secrets) | ? No (.gitignore) | Actual values (DO NOT COMMIT) |
| `deploy.ps1` | ? No | ? Yes | Deployment automation script |
| `.gitignore` | ? No | ? Yes | Prevents committing secrets |

---

## Secure Workflow Summary

### Step 1: Get Your Subscription ID
```powershell
az login
az account list --output table
# Copy the SubscriptionId you want to use
```

### Step 2: Deploy Using Script (Recommended)
```powershell
cd C:\Users\Vijay\terraform-infra
.\deploy.ps1 -SubscriptionId "YOUR-ACTUAL-SUBSCRIPTION-ID" -AutoApprove
```

### Step 3: Verify No Secrets in Git
```powershell
git status
# ? GOOD: terraform.tfvars should NOT be listed (it's in .gitignore)
# ? BAD: If terraform.tfvars appears, don't commit it
```

### Step 4: Commit and Push
```powershell
git add .
git commit -m "Your commit message"
git push origin main
```

---

## Environment Variables (Recommended for CI/CD)

For automated pipelines (GitHub Actions, Azure DevOps), use environment variables:

```powershell
# GitHub Actions example
$env:TF_VAR_subscription_id = $subscriptionId
$env:TF_VAR_admin_password = $adminPassword

terraform apply -auto-approve
```

---

## What Gets Committed vs Not

### ? COMMITTED TO GIT:
```
providers.tf                 # Provider setup
variables.tf                 # Variable declarations
main.tf                      # Infrastructure code
outputs.tf                   # Output definitions
deploy.ps1                   # Deployment script
README.md                    # Documentation
HOW_VARIABLES_WORK.md        # Variable guide
.gitignore                   # Git exclusions
terraform.tfvars.example     # Example template
```

### ? NOT COMMITTED (Protected by .gitignore):
```
terraform.tfvars             # Your actual secrets
.terraform/                  # Terraform cache
*.tfstate                    # State files
*.tfstate.*                  # State backups
tfplan                       # Plan files
```

---

## Checking for Accidentally Committed Secrets

```powershell
# See what would be committed
git status

# See the diff before committing
git diff --cached

# If terraform.tfvars was accidentally added to staging
git reset HEAD terraform.tfvars

# Verify it was removed
git status
```

---

## Recovery if Accidentally Committed

If you accidentally committed the file:

```powershell
# Remove from Git history (one-time only)
git rm --cached terraform.tfvars
git commit -m "Remove terraform.tfvars from tracking"

# For safety on older commits, rotate all secrets
az account get-access-token --subscription "YOUR-ID"
```

---

## Best Practices Summary

? **DO:**
- Use `deploy.ps1 -SubscriptionId "..."` for deployments
- Use environment variables for CI/CD
- Check `git status` before pushing
- Keep `.gitignore` updated
- Use Azure Key Vault for long-term secret storage

? **DON'T:**
- Commit `terraform.tfvars` to Git
- Hardcode subscription IDs in scripts
- Share terraform.tfvars in emails or messages
- Use default credentials in production
- Skip the `.gitignore` file

---

## Viewing Terraform Outputs After Deployment

```powershell
# Get the public IP of deployed VM
terraform output public_ip_address

# Get all outputs
terraform output

# Get specific output as JSON
terraform output -json public_ip_address
```

---

## Questions or Issues?

If you accidentally committed secrets:
1. Run `git reset HEAD~1` (undo last commit - use carefully!)
2. Rotate all secrets immediately
3. Force push if already pushed (risky - coordinate with team)

For GitHub repos, consider using:
- **GitHub Secrets** for Actions
- **Azure Key Vault** for production
- **Terraform Cloud** for state and secrets management

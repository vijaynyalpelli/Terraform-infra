# ? Pre-Push Checklist

## Before Running `git push origin main`

### Security Verification
- [ ] `terraform.tfvars` is NOT shown in `git status`
- [ ] No subscription IDs in committed files
- [ ] No passwords in committed files
- [ ] `.gitignore` contains `terraform.tfvars`
- [ ] All `.tf` files have no hardcoded secrets

### Commit Verification
```powershell
# Run these commands:
git status                    # Should show "nothing to commit"
git ls-files | wc -l         # Count of tracked files
git ls-remote --heads origin  # See remote branches
```

Expected output:
```
On branch main
Your branch is ahead of 'origin/main' by 3 commits.

nothing added to commit but untracked files present
```

### Files Safe to Push
? `main.tf` — Infrastructure code
? `variables.tf` — Variable declarations  
? `providers.tf` — Provider config
? `outputs.tf` — Output definitions
? `deploy.ps1` — Deployment script
? `README.md` — Documentation
? `SECURE_DEPLOYMENT_GUIDE.md` — Security guide
? `HOW_VARIABLES_WORK.md` — Learning guide
? `SUBSCRIPTION_ID_REMOVAL_SUMMARY.md` — Summary
? `.gitignore` — Protection rules
? `IIS Install Scripts/install-iis.ps1` — IIS setup script

### Files Protected (Will NOT Push)
? `terraform.tfvars` — Has your subscription ID & password
? `.terraform/` — Terraform cache
? `*.tfstate` — State files
? `tfplan` — Plan files

---

## Push Command

When ready to push:

```powershell
git log --oneline -3          # See your commits
git push origin main          # Push to GitHub
```

---

## What Will Be Public on GitHub

After push, anyone can see:
- Infrastructure as Code (safe)
- Deployment automation script (safe)
- Security guidelines (safe)

**NO ONE can see:**
- Your Azure subscription ID ?
- Your admin password ?
- Your terraform state ?
- Terraform execution files ?

---

## After Push

1. Verify on GitHub:
   - Go to: https://github.com/vijaynyalpelli/Terraform-infra
   - Check that `terraform.tfvars` is NOT in the repo
   - Check that all `.tf` files are visible

2. Clone in another location to verify:
   ```powershell
   git clone https://github.com/vijaynyalpelli/Terraform-infra
   # Should NOT have terraform.tfvars
   # Should have terraform.tfvars.example or equivalent
   ```

---

## Current Git Status

```
Commits ahead of origin: 3
  - d82b8d6: Add secure deployment guide
  - 58ce517: Add subscription ID removal summary  
  - 4b21dce: Cleanup duplicate files
```

---

## Ready to Push? ?

```powershell
cd C:\Users\Vijay\terraform-infra
git push origin main
```

Then verify on GitHub!

# GitHub Actions Workflows - Setup Guide

## Workflows Created

### 1. **terraform-ci.yml** (Continuous Integration - On Every Push/PR)
- **Trigger:** Automatic on push to `main` or any pull request
- **What it does:**
  - ? Checks Terraform format (`terraform fmt`)
  - ? Initializes Terraform (`terraform init`)
  - ? Validates syntax (`terraform validate`)
  - ? Runs plan without applying (`terraform plan -no-color`)
  - ? Comments plan output on PRs
  - ? **Does NOT deploy** (apply is commented out)
- **Status:** Safe to run automatically on every checkin
- **Output:** Plan summary in PR comments, GitHub Step Summary

### 2. **terraform-deploy.yml** (Continuous Deployment - Manual Only)
- **Trigger:** Manual workflow dispatch via GitHub UI or API (must be explicitly triggered)
- **What it does:**
  - ?? Requires manual approval (GitHub environment protection)
  - ?? Logs actor, timestamp, commit ref, run URL for audit trail
  - ?? Allows choice of action: `plan`, `apply`, or `destroy`
  - ?? Executes `terraform apply` or `terraform destroy` only when requested
- **Status:** Safe because it's manual + requires approval
- **Output:** Terraform output, deployment summary with full context

---

## Required Setup (One-time)

### ?? CRITICAL: Azure Authentication Currently Disabled for Safety

Both workflows have Azure authentication steps **disabled by default** to prevent:
- Accidental Azure API calls during CI (which incur costs)
- Unintended resource deployments or modifications
- Credential exposure in logs

The workflows will currently fail with:
```
ERROR: Please run 'az login' to setup account
```

This is **intentional and safe**:
- **CI workflow** (`terraform-ci.yml`): Only validates Terraform syntax; no Azure calls
- **CD workflow** (`terraform-deploy.yml`): Fails until you enable authentication and secrets

---

### Step 1: Add GitHub Secrets
Go to repo Settings ? Secrets and variables ? Actions ? New repository secret:

1. `AZURE_CLIENT_ID` = Azure service principal client ID
   Example: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

2. `AZURE_TENANT_ID` = Azure AD tenant ID
   Example: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

3. `AZURE_SUBSCRIPTION_ID` = your Azure subscription ID
   Example: `b0a65222-af08-42ca-9e96-f990066d7573`

4. `ADMIN_PASSWORD` = strong Azure admin password
   Example: `P@ssw0rd1234!` (must meet Azure complexity rules)

**?? DO NOT** commit these to the repo; GitHub Actions accesses them securely.

---

### Step 1b: Create Azure Service Principal (One-time)

Create a service principal for GitHub Actions with necessary Azure permissions:

```bash
az ad sp create-for-rbac \
  --name "terraform-github-actions" \
  --role Contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID>
```

Output will include:
- `clientId` ? use as `AZURE_CLIENT_ID` secret
- `tenantId` ? use as `AZURE_TENANT_ID` secret
- `clientSecret` ? save securely (not stored in GitHub; use OIDC instead)

**Better approach: Use OIDC (Federated Credentials)** instead of storing client secrets.
See: https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure

---

### Step 2: Create GitHub Environment (Optional but Recommended)
To require approval before `terraform-deploy.yml` runs:

1. Go to repo Settings ? Environments ? New environment
2. Name it: `production`
3. Add required reviewers (your team leads)
4. Optional: Restrict deployment branches to `main`

Now any manual deployment workflow must be approved by a reviewer.

---

## How to Use

### CI Workflow (Automatic - Every Checkin)
**No action needed.** When you push or create a PR:
1. Workflow runs automatically
2. Validates Terraform syntax and formatting
3. **No Azure authentication occurs** (safely disabled)
4. If validation fails, it's visible in PR + Actions tab
5. No Azure costs incurred

**Expected output:**
- ? Format check passes/fails
- ? Validation passes (syntax OK)
- ? Plan step fails (Azure auth disabled - this is safe)
- Summary shows safe/incomplete status

### CD Workflow (Manual - Deploy Only)
**?? Currently disabled for safety.**

To deploy infrastructure, you must first:
1. Enable Azure authentication (see "Enabling Deployment" section below)
2. Add GitHub secrets
3. Manually trigger the workflow

---

## Enabling Deployment (Optional - Do This Only When Ready)

### When to Enable Deployment

Enable deployment workflows only when:
- [ ] You have added all GitHub secrets (AZURE_CLIENT_ID, AZURE_TENANT_ID, AZURE_SUBSCRIPTION_ID, ADMIN_PASSWORD)
- [ ] You have created a service principal in Azure
- [ ] You understand that enabling this allows workflows to create/modify/delete Azure resources
- [ ] You have set up environment approval (production environment with required reviewers)
- [ ] Your team has reviewed the security implications

### Steps to Enable Deployment

1. **Uncomment Azure Login Step in terraform-deploy.yml**
   - Open `.github/workflows/terraform-deploy.yml`
   - Find the `# - name: Azure Login (OIDC - Recommended)` section
   - Uncomment the entire block (remove the `#` from each line)
   - Ensure the secrets match those added in GitHub

2. **Uncomment Azure Login Step in terraform-ci.yml (optional)**
   - If you want CI to also validate against Azure: uncomment the Azure Login section
   - Otherwise, leave commented (safer - CI only validates syntax)

3. **Set Up Environment Approval**
   - Go to GitHub repo Settings ? Environments ? Create "production" environment
   - Add required reviewers (your team leads)
   - Now any deployment requires approval

4. **Test with Plan First**
   - Go to Actions ? Terraform Deploy (Manual - CD)
   - Run workflow with `terraform_action = "plan"`
   - Verify the plan looks correct
   - Only then run with `"apply"`

5. **Commit and Push Workflow Changes**
   - Commit the uncommented workflow file
   - Push to main branch
   - Workflows will be active on next trigger

---

### CD Workflow (Manual - Deploy) - Current Status
**Status: DISABLED (Azure auth commented out)**

When you manually trigger it (once enabled):

1. Go to GitHub repo ? Actions ? Terraform Deploy (Manual - CD)
2. Click "Run workflow" button
3. Choose action:
   - `plan` — preview changes (safe - read-only)
   - `apply` — create/update resources (requires approval)
   - `destroy` — delete resources (requires approval)
4. Click "Run workflow"
5. If environment approval is enabled, wait for reviewer to approve
6. Workflow executes; see logs and output in Actions tab

---

## Key Security Features

| Feature | Benefit |
|---------|---------|
| **CI syntax only** | Prevents accidental deploys on code checkin |
| **Azure auth disabled by default** | Prevents unintended Azure API calls |
| **Manual trigger only** | Only explicit user action triggers deployment |
| **GitHub Secrets** | Azure creds never exposed in code/logs |
| **Environment approval** | Requires human review before deploying |
| **Audit logging** | Actor, timestamp, commit ref recorded |
| **Separate workflows** | CI (safe, fast) vs CD (gated, deliberate) |
| **Comments in workflows** | Clear instructions on enabling deployment |

---

## Current Status

### CI Workflow
- ? Active and runs automatically
- ? Validates Terraform syntax
- ? Azure auth disabled (safe)
- ? Plan will fail (expected)

### CD Workflow
- ? Disabled by default
- ?? Requires manual trigger via GitHub UI
- ?? Azure auth commented out
- ?? Apply/Destroy steps will fail until enabled
- ??  Will only deploy when explicitly enabled + triggered + approved

---

## Troubleshooting

### CI Workflow: Plan fails with "Please run 'az login' to setup account"
- **Expected behavior** - Azure auth is disabled for safety
- **If you want CI to validate Azure:** Uncomment the Azure Login step in terraform-ci.yml

### CD Workflow: Can't run deployment
- **Check 1:** Are GitHub secrets added? (Settings ? Secrets)
- **Check 2:** Have you uncommented the Azure Login step?
- **Check 3:** Is the environment approval set up? (Settings ? Environments)
- **Check 4:** Is the workflow file on main branch?

### Manual workflow dispatch not showing "Run workflow" button
- The workflow file must be on the main branch
- Refresh the Actions tab
- Check file is `.github/workflows/terraform-deploy.yml`

---

## Next Steps

### Option 1: Keep Deployment Disabled (Safe Default)
- Do nothing - workflows stay safely disabled
- Deploy manually using `./deploy.ps1` from your local machine
- Run `terraform apply` locally after `terraform plan`

### Option 2: Enable Deployment Later
- Follow "Enabling Deployment" section when ready
- Set up service principal and GitHub secrets
- Uncomment Azure Login steps in workflows
- Test with plan first, then apply

### For Now (Recommended)
1. ? Push workflows to main branch
2. ? Test CI workflow: make a PR, watch it validate
3. ? Leave deployment disabled for safety
4. ? Continue using `./deploy.ps1` for manual deployments
5. ? Enable deployment workflows later after security review


# Terraform-infra

## Project description

This repository contains sample Terraform configurations that provision a Windows Server virtual machine in Azure and install a web server (IIS) on it. The examples demonstrate how to:

- Create and configure a Windows VM using Terraform (AzureRM provider).
- Provision the VM at deploy-time to install and configure IIS.
- Parameterize deployments using Terraform variables and a sample `terraform.tfvars`.
- Apply idempotent, repeatable infrastructure deployments suitable for CI/CD.

These scripts are educational samples and starting points for deploying Windows-based web workloads. Review, adapt, and secure them before using in production.

## Contents

- `providers.tf` — Terraform settings and provider configuration (`azurerm`).
- `main.tf` — Primary resources (resource group, VNet, subnet, public IP, NIC, Windows VM, extension to install IIS).
- `variables.tf` — Input variables with comments and defaults.
- `outputs.tf` — Useful outputs after apply (public IP, VM name).
- `terraform.tfvars.example` — Example variable values to copy to `terraform.tfvars`.
`IIS Install Scripts/install-iis.ps1` — PowerShell script to install IIS and deploy a sample index.html.

## Prerequisites

- Terraform 1.0+ installed.
- Azure CLI or other method to authenticate the AzureRM provider (`az login` or service principal).
- A secure way to provide secrets (do not commit `admin_password` to source control).

## Quick start

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update values (do not commit secrets).
2. Run `terraform init` to initialize providers.
3. Run `terraform plan` to preview changes.
4. Run `terraform apply` to create resources and provision the VM.
5. Use `terraform output public_ip_address` to get the site IP and visit it in a browser.

## Cleanup

Run `terraform destroy` to remove resources when finished.

## Notes

- This sample uses the Azure `CustomScriptExtension` to run inline PowerShell that installs IIS. For production, host `scripts/install-iis.ps1` in a secure storage and reference it from the VM extension using `fileUris`.
- Consider adding Network Security Groups (NSGs) and Azure Key Vault for secrets in real deployments.

## License

MIT

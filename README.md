# Terraform-infra

## Project description

This repository contains sample Terraform configurations that provision a Windows Server virtual machine and install a web server (IIS) on it. The examples demonstrate how to:

- Create and configure a Windows VM using Terraform.
- Provision the VM at deploy-time to install and configure IIS (Microsoft Internet Information Services).
- Parameterize deployments using Terraform variables and modular configuration.
- Apply idempotent, repeatable infrastructure deployments suitable for CI/CD.

These scripts are intended as educational samples and starting points for deploying Windows-based web workloads in cloud or lab environments. Review, adapt, and secure them before using in production.

## Contents

- `main.tf` — Primary Terraform configuration for provisioning resources.
- `variables.tf` — Input variables and defaults.
- `outputs.tf` — Outputs exported by the configuration.
- `scripts/install-iis.ps1` — PowerShell provisioning script executed on the VM to install and configure IIS.
- `modules/` — Optional reusable modules.

## Prerequisites

- Terraform 1.0 or later installed locally.
- Credentials and provider configuration for your chosen cloud provider (Azure, AWS, etc.).
- Network and security considerations (open ports for RDP and HTTP/HTTPS as appropriate).

## Quick start

1. Configure provider credentials (see provider-specific docs).
2. Edit `variables.tf` or provide a `terraform.tfvars` file with required values.
3. Run `terraform init` to initialize the working directory.
4. Run `terraform plan` to preview changes.
5. Run `terraform apply` to create resources and provision the VM.

## Provisioning and customization

The repository uses a PowerShell provisioning script (`scripts/install-iis.ps1`) that runs on first boot to install IIS and deploy a sample site. Modify the script to customize site content, implement security hardening, or to install additional software.

## Security and cleanup

- Use secure methods to store credentials (environment variables, managed identities, or secret stores).
- Remove or destroy resources after testing with `terraform destroy` to avoid unexpected costs.

## License

This project is provided under the MIT License — see `LICENSE` for details.

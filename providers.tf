# Terraform and Provider Configuration
# This file defines the required Terraform version and configures the Azure Resource Manager provider.

terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure the Azure Resource Manager Provider
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

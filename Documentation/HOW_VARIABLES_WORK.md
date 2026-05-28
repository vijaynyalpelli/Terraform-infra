# How Terraform Variables Work: variables.tf ? terraform.tfvars

## The Connection Explained

Terraform links `variables.tf` and `terraform.tfvars` **by variable name matching**.

---

## Step-by-Step Flow

### **Step 1: Variable Declaration** (`variables.tf`)
In `variables.tf`, you **declare** what variables exist and their properties:

```hcl
variable "subscription_id" {
  description = "Azure subscription ID to deploy resources into."
  type        = string
}
```

This says:
- ? A variable named `subscription_id` exists
- ? It must be a string type
- ? No default value (required input)

### **Step 2: Variable Assignment** (`terraform.tfvars`)
In `terraform.tfvars`, you **assign actual values** to those variables:

```hcl
subscription_id = "12345678-1234-1234-1234-123456789abc"
```

This says:
- ? Set the variable named `subscription_id` to this value

### **Step 3: Variable Usage** (in `main.tf`, `providers.tf`, etc.)
In your Terraform files, you **reference** variables:

```hcl
provider "azurerm" {
  features {}
  subscription_id = var.subscription_id  # ? References the variable
}
```

---

## Visual Matching Example

```
???????????????????????????????????????????????????????????????????
?                    variables.tf (DECLARATION)                   ?
???????????????????????????????????????????????????????????????????
? variable "subscription_id" {                                    ?
?   type = string                                                 ?
? }                                                               ?
?                                                                 ?
? variable "admin_password" {                                     ?
?   type = string                                                 ?
?   sensitive = true                                              ?
? }                                                               ?
?                                                                 ?
? variable "location" {                                           ?
?   type = string                                                 ?
?   default = "eastus"  ? Has default, so OPTIONAL               ?
? }                                                               ?
???????????????????????????????????????????????????????????????????
                              ?
                    (NAME MATCHING)
                              ?
???????????????????????????????????????????????????????????????????
?              terraform.tfvars (ASSIGNMENT/VALUES)               ?
???????????????????????????????????????????????????????????????????
? subscription_id = "12345678-1234-..."  ? Matches var name       ?
? admin_password = "MyPassword123!"      ? Matches var name       ?
? location = "westus"                    ? Overrides default      ?
?                                                                 ?
? (NO ENTRY for variables with defaults - uses the default)      ?
???????????????????????????????????????????????????????????????????
                              ?
                    (USED IN TERRAFORM FILES)
                              ?
???????????????????????????????????????????????????????????????????
?        providers.tf / main.tf (USAGE/REFERENCE)                 ?
???????????????????????????????????????????????????????????????????
? provider "azurerm" {                                            ?
?   subscription_id = var.subscription_id                         ?
? }                                                               ?
?                                                                 ?
? resource "azurerm_windows_virtual_machine" "vm" {              ?
?   admin_password = var.admin_password                           ?
?   location = var.location                                       ?
? }                                                               ?
???????????????????????????????????????????????????????????????????
```

---

## Real-World Example

### **variables.tf (What variables CAN exist)**
```hcl
variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
  # NO default = REQUIRED in terraform.tfvars
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"  # Has default = OPTIONAL in terraform.tfvars
}

variable "admin_password" {
  type        = string
  sensitive   = true
  # NO default = REQUIRED in terraform.tfvars
}
```

### **terraform.tfvars (What values ARE used)**
```hcl
subscription_id = "abc-123-def-456"     # ? Matches subscription_id variable
admin_password = "SecurePass123!"       # ? Matches admin_password variable
# location NOT SET ? Uses default "eastus"
```

### **Terraform Execution**
Terraform will use:
- `var.subscription_id` = `"abc-123-def-456"`
- `var.admin_password` = `"SecurePass123!"`
- `var.location` = `"eastus"` (default, not overridden)

---

## Key Rules

| Scenario | What Happens |
|----------|--------------|
| Variable declared in `variables.tf` with **default** | Uses default if not in `terraform.tfvars` |
| Variable declared in `variables.tf` **without default** | **REQUIRED** in `terraform.tfvars` (error if missing) |
| Variable in `terraform.tfvars` **NOT** in `variables.tf` | Error: unknown variable |
| Variable name **mismatch** (e.g., `subcription_id` vs `subscription_id`) | Error: variable not found |

---

## Your Current Setup

### **Required in terraform.tfvars** (no defaults):
- `subscription_id` ? YOU MUST SET THIS
- `admin_password` ? YOU MUST SET THIS

### **Optional in terraform.tfvars** (have defaults):
- `location` = "eastus"
- `resource_group_name` = "rg-terraform-windows"
- `vm_name` = "win-iis-vm"
- `vm_size` = "Standard_B2s"
- `admin_username` = "azureuser"
- `vnet_name` = "vnet-terraform"
- `vnet_address_space` = ["10.0.0.0/16"]
- `subnet_name` = "subnet-01"
- `subnet_prefix` = "10.0.1.0/24"
- `public_ip_sku` = "Basic"
- `image_publisher` = "MicrosoftWindowsServer"
- `image_offer` = "WindowsServer"
- `image_sku` = "2019-Datacenter"
- `os_disk_size_gb` = 30

---

## How Terraform Finds `terraform.tfvars`

When you run `terraform plan` or `terraform apply`:

1. Terraform looks for a file named `terraform.tfvars` in the current directory
2. If found, it **automatically loads** it (no -var-file flag needed)
3. It matches variable names and assigns values
4. If a required variable is missing ? **Error**
5. If a variable has a default ? uses default if not provided

---

## File Loading Order (Priority)

Terraform loads variables in this order (last wins):
1. Command-line: `terraform apply -var="location=westus"`
2. `terraform.tfvars` file (automatic)
3. `*.auto.tfvars` files (all loaded alphabetically)
4. Environment variables: `TF_VAR_location=westus`
5. Default values in `variables.tf`

---

## Summary

```
variables.tf     ?  DEFINES what variables exist
     ?
terraform.tfvars ?  PROVIDES values for those variables
     ?
Terraform Code   ?  USES var.name to reference values
```

**The connection is AUTOMATIC based on variable name matching.**

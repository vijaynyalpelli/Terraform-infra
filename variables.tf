// Input variables with descriptive comments to explain purpose and typical values.

variable "location" {
  description = "Azure region to deploy resources into."
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Name of the resource group to create."
  type        = string
  default     = "rg-terraform-windows"
}

variable "vm_name" {
  description = "Name of the Windows virtual machine."
  type        = string
  default     = "win-iis-vm"
}

variable "vm_size" {
  description = "Azure VM size SKU."
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username for the Windows VM."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Administrator password for the Windows VM. Use secrets in production (do not commit)."
  type        = string
  sensitive   = true
}

variable "vnet_name" {
  description = "Virtual network name."
  type        = string
  default     = "vnet-terraform"
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Subnet name inside the VNet."
  type        = string
  default     = "subnet-01"
}

variable "subnet_prefix" {
  description = "Subnet CIDR within the VNet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_ip_sku" {
  description = "Public IP SKU (Basic or Standard)."
  type        = string
  default     = "Basic"
}

variable "image_publisher" {
  description = "Image publisher for Windows VM."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
  description = "Image offer for Windows VM."
  type        = string
  default     = "WindowsServer"
}

variable "image_sku" {
  description = "Image SKU for Windows VM (version)."
  type        = string
  default     = "2019-Datacenter"
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB."
  type        = number
  default     = 30
}

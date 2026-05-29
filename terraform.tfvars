# Copy this file to terraform.tfvars and replace placeholder values.
# Do NOT commit secrets to source control.

subscription_id = "b0a65222-af08-42ca-9e96-f990066d7573"
location            = "eastus"
resource_group_name = "rg-terraform-windows"
vm_name             = "win-iis-vm"
vm_size             = "Standard_B2s"
admin_username      = "azureuser"
# Use a secure password in real deployments. Prefer secrets / Key Vault.
admin_password      = "P@ssw0rd1234!"
vnet_name           = "vnet-terraform"
vnet_address_space  = ["10.0.0.0/16"]
subnet_name         = "subnet-01"
subnet_prefix       = "10.0.1.0/24"
public_ip_sku       = "Basic"
image_publisher     = "MicrosoftWindowsServer"
image_offer         = "WindowsServer"
image_sku           = "2019-Datacenter"
os_disk_size_gb     = 127




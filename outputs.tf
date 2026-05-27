output "public_ip_address" {
  description = "Public IP address assigned to the VM (note: dynamic assignment may change on stop/deallocate)."
  value       = azurerm_public_ip.pip.ip_address
}

output "vm_name" {
  description = "Name of the deployed VM."
  value       = azurerm_windows_virtual_machine.vm.name
}

output "admin_username" {
  description = "Administrator username for the VM (do not output passwords in real projects)."
  value       = var.admin_username
}

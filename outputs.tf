###############################################################################
# Outputs - Azure Container Registry Module
###############################################################################

output "acr_id" {
  description = "The resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.this.id
}

output "acr_name" {
  description = "The name of the Azure Container Registry."
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "The URL used to log into the ACR (e.g. myregistry.azurecr.io)."
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "The admin username for the ACR (only populated when admin_enabled = true)."
  value       = azurerm_container_registry.this.admin_username
  sensitive   = true
}

output "admin_password" {
  description = "The admin password for the ACR (only populated when admin_enabled = true)."
  value       = azurerm_container_registry.this.admin_password
  sensitive   = true
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned managed identity (if enabled)."
  value       = try(azurerm_container_registry.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the system-assigned managed identity (if enabled)."
  value       = try(azurerm_container_registry.this.identity[0].tenant_id, null)
}

output "resource_group_name" {
  description = "The name of the resource group the ACR belongs to."
  value       = local.resource_group_name
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint (if created)."
  value       = try(azurerm_private_endpoint.this[0].private_service_connection[0].private_ip_address, null)
}

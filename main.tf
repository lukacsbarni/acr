###############################################################################
# Azure Container Registry (ACR) - Terraform Module
###############################################################################

# ------------------------------------------------------------------------------
# Resource Group (optional - only created if create_resource_group = true)
# ------------------------------------------------------------------------------
resource "azurerm_resource_group" "this" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

locals {
  resource_group_name = var.create_resource_group ? azurerm_resource_group.this[0].name : var.resource_group_name
}

# ------------------------------------------------------------------------------
# Azure Container Registry
# ------------------------------------------------------------------------------
resource "azurerm_container_registry" "this" {
  name                = var.acr_name
  resource_group_name = local.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  # Anonymous pull (Standard and Premium only)
  anonymous_pull_enabled = contains(["Standard", "Premium"], var.sku) ? var.anonymous_pull_enabled : false

  # Public network access (Premium only - Basic/Standard are always publicly accessible)
  public_network_access_enabled = var.sku == "Premium" ? var.public_network_access_enabled : true

  # Network rule bypass option (Premium only)
  network_rule_bypass_option = var.sku == "Premium" ? var.network_rule_bypass_option : "AzureServices"

  # Data endpoint (Premium only)
  data_endpoint_enabled = var.sku == "Premium" ? var.data_endpoint_enabled : false

  # Zone redundancy (Premium only - forces new resource if changed)
  zone_redundancy_enabled = var.sku == "Premium" ? var.zone_redundancy_enabled : false

  # Export policy (Premium only)
  export_policy_enabled = var.sku == "Premium" ? var.export_policy_enabled : true

  # Quarantine policy (Premium only)
  quarantine_policy_enabled = var.sku == "Premium" ? var.quarantine_policy_enabled : false

  # Retention policy in days (Premium only)
  retention_policy_in_days = var.sku == "Premium" ? var.retention_policy_in_days : null

  # Trust policy (Premium only)
  trust_policy_enabled = var.sku == "Premium" ? var.trust_policy_enabled : false

  # Network rule set (Premium only)
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && length(var.network_rule_set) > 0 ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = lookup(network_rule_set.value, "ip_rules", [])
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }

      dynamic "virtual_network_rule" {
        for_each = lookup(network_rule_set.value, "virtual_networks", [])
        content {
          action    = virtual_network_rule.value.action
          subnet_id = virtual_network_rule.value.subnet_id
        }
      }
    }
  }

  # Geo-replication (Premium only)
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = lookup(georeplications.value, "regional_endpoint_enabled", false)
      zone_redundancy_enabled   = lookup(georeplications.value, "zone_redundancy_enabled", false)
      tags                      = lookup(georeplications.value, "tags", var.tags)
    }
  }

  # Managed Identity
  identity {
    type         = var.identity_type
    identity_ids = var.identity_ids
  }

  # Customer-Managed Key encryption (Premium only)
  dynamic "encryption" {
    for_each = var.encryption != null && var.sku == "Premium" ? [var.encryption] : []
    content {
      key_vault_key_id   = encryption.value.key_vault_key_id
      identity_client_id = encryption.value.identity_client_id
    }
  }

  tags = var.tags
}

# ------------------------------------------------------------------------------
# Diagnostic Settings (optional)
# ------------------------------------------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.diagnostic_settings != null ? 1 : 0
  name                       = var.diagnostic_settings.name
  target_resource_id         = azurerm_container_registry.this.id
  log_analytics_workspace_id = lookup(var.diagnostic_settings, "log_analytics_workspace_id", null)
  storage_account_id         = lookup(var.diagnostic_settings, "storage_account_id", null)

  dynamic "enabled_log" {
    for_each = lookup(var.diagnostic_settings, "log_categories", [])
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = lookup(var.diagnostic_settings, "metric_categories", ["AllMetrics"])
    content {
      category = metric.value
    }
  }
}

# ------------------------------------------------------------------------------
# Role Assignments (optional)
# ------------------------------------------------------------------------------
resource "azurerm_role_assignment" "this" {
  for_each             = { for ra in var.role_assignments : "${ra.principal_id}-${ra.role_definition_name}" => ra }
  scope                = azurerm_container_registry.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

# ------------------------------------------------------------------------------
# Private Endpoint (optional, Premium recommended)
# ------------------------------------------------------------------------------
resource "azurerm_private_endpoint" "this" {
  count               = var.private_endpoint != null ? 1 : 0
  name                = var.private_endpoint.name
  location            = var.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.private_endpoint.subnet_id

  private_service_connection {
    name                           = "${var.acr_name}-psc"
    private_connection_resource_id = azurerm_container_registry.this.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(lookup(var.private_endpoint, "private_dns_zone_ids", [])) > 0 ? [1] : []
    content {
      name                 = "${var.acr_name}-dns-group"
      private_dns_zone_ids = var.private_endpoint.private_dns_zone_ids
    }
  }

  tags = var.tags
}

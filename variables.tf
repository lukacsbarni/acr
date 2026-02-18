###############################################################################
# Variables - Azure Container Registry Module
###############################################################################

# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------
variable "acr_name" {
  description = "Name of the Azure Container Registry. Must be globally unique, 5-50 alphanumeric characters."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.acr_name))
    error_message = "ACR name must be 5-50 alphanumeric characters (no hyphens or underscores)."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group in which to create the ACR."
  type        = string
}

variable "create_resource_group" {
  description = "If true, a new resource group is created. If false, the existing resource group referenced by resource_group_name is used."
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure region where the ACR will be deployed (e.g. 'eastus', 'westeurope')."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# SKU & Core Settings
# ------------------------------------------------------------------------------
variable "sku" {
  description = "The SKU of the ACR. Allowed values: Basic, Standard, Premium."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  description = "Enable the admin user for the registry. Not recommended for production; use RBAC instead."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow public network access to the ACR."
  type        = bool
  default     = true
}

variable "data_endpoint_enabled" {
  description = "(Premium only) Enable a dedicated data endpoint for the registry."
  type        = bool
  default     = false
}

variable "zone_redundancy_enabled" {
  description = "(Premium only) Enable zone redundancy for the registry."
  type        = bool
  default     = false
}

variable "export_policy_enabled" {
  description = "(Premium only) Allow artifacts to be exported from the registry."
  type        = bool
  default     = true
}

variable "network_rule_bypass_option" {
  description = "Allow trusted Azure services to bypass network rules. Allowed values: AzureServices, None."
  type        = string
  default     = "AzureServices"
  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "network_rule_bypass_option must be 'AzureServices' or 'None'."
  }
}

# ------------------------------------------------------------------------------
# Network Rules (Premium only)
# ------------------------------------------------------------------------------
variable "network_rule_set" {
  description = <<EOT
(Premium only) Network rule set for the ACR.
Example:
  network_rule_set = {
    default_action = "Deny"
    ip_rules = [
      { action = "Allow", ip_range = "1.2.3.4/32" }
    ]
    virtual_networks = [
      { action = "Allow", subnet_id = "/subscriptions/..." }
    ]
  }
EOT
  type        = any
  default     = {}
}

# ------------------------------------------------------------------------------
# Geo-Replication (Premium only)
# ------------------------------------------------------------------------------
variable "georeplications" {
  description = <<EOT
(Premium only) List of geo-replication locations.
Example:
  georeplications = [
    {
      location                  = "westeurope"
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = true
    }
  ]
EOT
  type        = any
  default     = []
}

# ------------------------------------------------------------------------------
# Retention Policy (Premium only)
# ------------------------------------------------------------------------------
variable "retention_policy" {
  description = <<EOT
(Premium only) Retention policy for untagged manifests.
Example:
  retention_policy = {
    days    = 30
    enabled = true
  }
EOT
  type = object({
    days    = number
    enabled = bool
  })
  default = null
}

# ------------------------------------------------------------------------------
# Trust Policy (Premium only)
# ------------------------------------------------------------------------------
variable "trust_policy" {
  description = <<EOT
(Premium only) Enable content trust (Docker Content Trust).
Example:
  trust_policy = {
    enabled = true
  }
EOT
  type = object({
    enabled = bool
  })
  default = null
}

# ------------------------------------------------------------------------------
# Identity
# ------------------------------------------------------------------------------
variable "identity_type" {
  description = "Type of managed identity. Allowed values: None, SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  type        = string
  default     = "SystemAssigned"
}

variable "identity_ids" {
  description = "List of user-assigned managed identity IDs. Required when identity_type includes UserAssigned."
  type        = list(string)
  default     = null
}

# ------------------------------------------------------------------------------
# Encryption (Premium only)
# ------------------------------------------------------------------------------
variable "encryption" {
  description = <<EOT
(Premium only) Customer-managed key encryption settings.
Example:
  encryption = {
    enabled            = true
    key_vault_key_id   = "/subscriptions/.../keys/mykey/..."
    identity_client_id = "00000000-0000-0000-0000-000000000000"
  }
EOT
  type = object({
    enabled            = bool
    key_vault_key_id   = string
    identity_client_id = string
  })
  default = null
}

# ------------------------------------------------------------------------------
# Diagnostic Settings
# ------------------------------------------------------------------------------
variable "diagnostic_settings" {
  description = <<EOT
Optional diagnostic settings to forward logs/metrics.
Example:
  diagnostic_settings = {
    name                       = "acr-diag"
    log_analytics_workspace_id = "/subscriptions/.../workspaces/mylaw"
    log_categories             = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
    metric_categories          = ["AllMetrics"]
  }
EOT
  type        = any
  default     = null
}

# ------------------------------------------------------------------------------
# Role Assignments
# ------------------------------------------------------------------------------
variable "role_assignments" {
  description = <<EOT
List of role assignments to create on the ACR.
Example:
  role_assignments = [
    {
      principal_id         = "00000000-0000-0000-0000-000000000000"
      role_definition_name = "AcrPull"
    },
    {
      principal_id         = "11111111-1111-1111-1111-111111111111"
      role_definition_name = "AcrPush"
    }
  ]
EOT
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []
}

# ------------------------------------------------------------------------------
# Private Endpoint
# ------------------------------------------------------------------------------
variable "private_endpoint" {
  description = <<EOT
Optional private endpoint configuration.
Example:
  private_endpoint = {
    name                 = "acr-pe"
    subnet_id            = "/subscriptions/.../subnets/mysubnet"
    private_dns_zone_ids = ["/subscriptions/.../privateDnsZones/privatelink.azurecr.io"]
  }
EOT
  type        = any
  default     = null
}

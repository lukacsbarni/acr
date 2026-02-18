###############################################################################
# Example - Azure Container Registry Module Usage
###############################################################################

provider "azurerm" {
  features {}
}

# ------------------------------------------------------------------------------
# Example 1: Basic ACR (Standard SKU, minimal config)
# ------------------------------------------------------------------------------
module "acr_basic" {
  source = "./terraform-azure-acr"

  acr_name            = "myacrbasic"
  resource_group_name = "rg-acr-dev"
  location            = "eastus"

  sku           = "Standard"
  admin_enabled = false

  tags = {
    environment = "dev"
    team        = "platform"
  }
}

output "basic_login_server" {
  value = module.acr_basic.login_server
}

# ------------------------------------------------------------------------------
# Example 2: Premium ACR with geo-replication, private endpoint, RBAC
# ------------------------------------------------------------------------------
module "acr_premium" {
  source = "./terraform-azure-acr"

  acr_name              = "myacrpremium"
  resource_group_name   = "rg-acr-prod"
  create_resource_group = true
  location              = "eastus"

  sku           = "Premium"
  admin_enabled = false

  # Restrict public access
  public_network_access_enabled = false
  network_rule_bypass_option    = "AzureServices"

  # Geo-replication
  georeplications = [
    {
      location                  = "westeurope"
      regional_endpoint_enabled = true
      zone_redundancy_enabled   = true
    },
    {
      location                  = "southeastasia"
      regional_endpoint_enabled = false
      zone_redundancy_enabled   = false
    }
  ]

  # Retention: purge untagged manifests after 14 days
  retention_policy = {
    days    = 14
    enabled = true
  }

  # Content trust
  trust_policy = {
    enabled = true
  }

  # System-assigned identity
  identity_type = "SystemAssigned"

  # RBAC role assignments
  role_assignments = [
    {
      # AKS kubelet identity or app service principal - AcrPull
      principal_id         = "00000000-0000-0000-0000-000000000000"
      role_definition_name = "AcrPull"
    },
    {
      # CI/CD service principal - AcrPush
      principal_id         = "11111111-1111-1111-1111-111111111111"
      role_definition_name = "AcrPush"
    }
  ]

  # Private endpoint
  private_endpoint = {
    name      = "acr-premium-pe"
    subnet_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-prod/subnets/snet-endpoints"
    private_dns_zone_ids = [
      "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.azurecr.io"
    ]
  }

  # Diagnostic settings
  diagnostic_settings = {
    name                       = "acr-premium-diag"
    log_analytics_workspace_id = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-prod"
    log_categories = [
      "ContainerRegistryRepositoryEvents",
      "ContainerRegistryLoginEvents"
    ]
    metric_categories = ["AllMetrics"]
  }

  tags = {
    environment = "prod"
    team        = "platform"
    cost_center = "12345"
  }
}

output "premium_login_server" {
  value = module.acr_premium.login_server
}

output "premium_identity_principal_id" {
  value = module.acr_premium.identity_principal_id
}

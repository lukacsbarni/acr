# Terraform Module: Azure Container Registry (ACR)

A production-ready Terraform module for deploying Azure Container Registry, compatible with **azurerm v4.x** (tested on `4.58.0`).

## Features

- **All SKU tiers**: Basic, Standard, Premium
- **Network security**: IP rules, VNet service endpoints, private endpoints
- **Identity**: System-assigned and user-assigned managed identities
- **Geo-replication** (Premium)
- **Customer-managed key encryption** (Premium)
- **Content trust & retention policies** (Premium) — updated for v4.x API
- **Anonymous pull access** (Standard/Premium)
- **Quarantine policy** (Premium)
- **RBAC role assignments**
- **Diagnostic settings** (Log Analytics / Storage Account)

## Requirements

| Name      | Version     |
|-----------|-------------|
| terraform | >= 1.14.3    |
| azurerm   | ~> 4.58.0   |

## Usage

```hcl
module "acr" {
  source = "./terraform-azure-acr"

  acr_name            = "myregistry"
  resource_group_name = "rg-platform"
  location            = "eastus"
  sku                 = "Standard"

  tags = {
    environment = "prod"
  }
}
```

## Migrating from azurerm v3.x

The following **breaking changes** affect `azurerm_container_registry` in v4.x:

| v3.x | v4.x | Notes |
|------|------|-------|
| `retention_policy { days = 30, enabled = true }` | `retention_policy_in_days = 30` | Block replaced by a scalar property |
| `trust_policy { enabled = true }` | `trust_policy_enabled = true` | Block replaced by a scalar boolean |
| `encryption { enabled = true, key_vault_key_id = "...", identity_client_id = "..." }` | `encryption { key_vault_key_id = "...", identity_client_id = "..." }` | `enabled` field removed; toggle encryption by including or omitting the block |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `acr_name` | Name of the ACR (5–50 alphanumeric chars, globally unique) | `string` | — | ✅ |
| `resource_group_name` | Resource group name | `string` | — | ✅ |
| `location` | Azure region | `string` | — | ✅ |
| `create_resource_group` | Create the resource group if true | `bool` | `false` | |
| `sku` | SKU tier: Basic, Standard, Premium | `string` | `"Standard"` | |
| `admin_enabled` | Enable admin user (not recommended for prod) | `bool` | `false` | |
| `anonymous_pull_enabled` | Anonymous pull access (Standard/Premium) | `bool` | `false` | |
| `public_network_access_enabled` | Allow public network access (Premium only) | `bool` | `true` | |
| `network_rule_bypass_option` | Trusted Azure services bypass (Premium only) | `string` | `"AzureServices"` | |
| `data_endpoint_enabled` | Dedicated data endpoint (Premium) | `bool` | `false` | |
| `zone_redundancy_enabled` | Zone redundancy — forces new resource (Premium) | `bool` | `false` | |
| `export_policy_enabled` | Allow artifact export (Premium) | `bool` | `true` | |
| `quarantine_policy_enabled` | Quarantine policy (Premium) | `bool` | `false` | |
| `retention_policy_in_days` | Days to retain untagged manifests (Premium) — replaces v3 block | `number` | `null` | |
| `trust_policy_enabled` | Enable Docker Content Trust (Premium) — replaces v3 block | `bool` | `false` | |
| `network_rule_set` | IP and VNet network rules (Premium) | `any` | `{}` | |
| `georeplications` | Geo-replication locations in alphabetical order (Premium) | `any` | `[]` | |
| `identity_type` | Managed identity type | `string` | `"SystemAssigned"` | |
| `identity_ids` | User-assigned identity resource IDs | `list(string)` | `null` | |
| `encryption` | CMK encryption — omit `enabled` field (v4.x change) (Premium) | `object` | `null` | |
| `role_assignments` | RBAC role assignments on the ACR | `list(object)` | `[]` | |
| `private_endpoint` | Private endpoint configuration | `any` | `null` | |
| `diagnostic_settings` | Log Analytics / Storage diagnostic settings | `any` | `null` | |
| `tags` | Tags to apply to all resources | `map(string)` | `{}` | |

## Outputs

| Name | Description |
|------|-------------|
| `acr_id` | Resource ID of the ACR |
| `acr_name` | Name of the ACR |
| `login_server` | Login server URL (e.g. `myregistry.azurecr.io`) |
| `admin_username` | Admin username (sensitive) |
| `admin_password` | Admin password (sensitive) |
| `identity_principal_id` | System-assigned identity principal ID |
| `identity_tenant_id` | System-assigned identity tenant ID |
| `resource_group_name` | Resource group name |
| `private_endpoint_id` | Private endpoint resource ID |
| `private_endpoint_ip` | Private IP of the endpoint |

## Common ACR Roles

| Role | Use Case |
|------|----------|
| `AcrPull` | Read-only pull access (e.g. AKS nodes, app services) |
| `AcrPush` | Pull + push access (e.g. CI/CD pipelines) |
| `AcrDelete` | Pull, push, and delete |
| `AcrImageSigner` | Sign images (requires content trust) |

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Included storage | 10 GiB | 100 GiB | 500 GiB |
| Anonymous pull | ❌ | ✅ | ✅ |
| Public network access control | ❌ | ❌ | ✅ |
| Network rules / firewall | ❌ | ❌ | ✅ |
| Geo-replication | ❌ | ❌ | ✅ |
| Private endpoints | ❌ | ❌ | ✅ |
| CMK encryption | ❌ | ❌ | ✅ |
| Content trust | ❌ | ❌ | ✅ |
| Zone redundancy | ❌ | ❌ | ✅ |
| Retention policy | ❌ | ❌ | ✅ |
| Quarantine policy | ❌ | ❌ | ✅ |
| Data endpoint | ❌ | ❌ | ✅ |

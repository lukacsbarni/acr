# Terraform Module: Azure Container Registry (ACR)

A production-ready Terraform module for deploying Azure Container Registry with support for all SKU tiers and common enterprise features.

## Features

- **All SKU tiers**: Basic, Standard, Premium
- **Network security**: IP rules, VNet service endpoints, private endpoints
- **Identity**: System-assigned and user-assigned managed identities
- **Geo-replication** (Premium)
- **Customer-managed key encryption** (Premium)
- **Content trust / retention policies** (Premium)
- **RBAC role assignments**
- **Diagnostic settings** (Log Analytics / Storage Account)

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

See [`examples/main.tf`](./examples/main.tf) for more detailed usage patterns.

## Requirements

| Name      | Version   |
|-----------|-----------|
| terraform | >= 1.3.0  |
| azurerm   | >= 3.0.0  |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `acr_name` | Name of the ACR (5–50 alphanumeric chars, globally unique) | `string` | — | ✅ |
| `resource_group_name` | Resource group name | `string` | — | ✅ |
| `location` | Azure region | `string` | — | ✅ |
| `create_resource_group` | Create the resource group if true | `bool` | `false` | |
| `sku` | SKU tier: Basic, Standard, Premium | `string` | `"Standard"` | |
| `admin_enabled` | Enable admin user (not recommended for prod) | `bool` | `false` | |
| `public_network_access_enabled` | Allow public network access | `bool` | `true` | |
| `data_endpoint_enabled` | Dedicated data endpoint (Premium) | `bool` | `false` | |
| `zone_redundancy_enabled` | Zone redundancy (Premium) | `bool` | `false` | |
| `network_rule_set` | IP and VNet network rules (Premium) | `any` | `{}` | |
| `georeplications` | Geo-replication locations (Premium) | `any` | `[]` | |
| `retention_policy` | Untagged manifest retention (Premium) | `object` | `null` | |
| `trust_policy` | Content trust (Premium) | `object` | `null` | |
| `identity_type` | Managed identity type | `string` | `"SystemAssigned"` | |
| `identity_ids` | User-assigned identity IDs | `list(string)` | `null` | |
| `encryption` | CMK encryption settings (Premium) | `object` | `null` | |
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
| `Contributor` | Full management (avoid in prod) |

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Included storage | 10 GiB | 100 GiB | 500 GiB |
| Geo-replication | ❌ | ❌ | ✅ |
| Private endpoints | ❌ | ❌ | ✅ |
| Network rules | ❌ | ❌ | ✅ |
| CMK encryption | ❌ | ❌ | ✅ |
| Content trust | ❌ | ❌ | ✅ |
| Zone redundancy | ❌ | ❌ | ✅ |

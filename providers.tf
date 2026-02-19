###############################################################################
# Providers - Azure Container Registry Module
###############################################################################

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}

provider "azurerm" {
  features {}

  # Optionally set via environment variables:
  #   ARM_SUBSCRIPTION_ID, ARM_TENANT_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET
  # subscription_id = var.subscription_id
  # tenant_id       = var.tenant_id
}

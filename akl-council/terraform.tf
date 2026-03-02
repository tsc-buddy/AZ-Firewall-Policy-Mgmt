terraform {
  required_version = ">= 1.9.0"

  backend "azurerm" {
    # All values are supplied at runtime via -backend-config flags in CI.
    # To initialise locally, run:
    #   terraform init \
    #     -backend-config="resource_group_name=<rg>" \
    #     -backend-config="storage_account_name=<sa>" \
    #     -backend-config="container_name=tfstate" \
    #     -backend-config="key=akl-council/terraform.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

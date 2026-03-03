terraform {
  required_version = ">= 1.9.0"

  # Using local state for now. To switch to remote state, replace with:
  # backend "azurerm" {
  #   resource_group_name  = "rg-tfstate-gis-prod-nzn-01"
  #   storage_account_name = "satfstategisprod"
  #   container_name       = "tfstate"
  #   key                  = "akl-council/terraform.tfstate"
  # }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  # subscription_id is sourced from the ARM_SUBSCRIPTION_ID environment variable.
  # In CI this is set via the ARM_SUBSCRIPTION_ID env var in the workflow.
  # Locally: $env:ARM_SUBSCRIPTION_ID = "<your-subscription-id>"
}

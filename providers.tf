terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.67.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-state-projectA-dev-spain-001"
    storage_account_name = "ststateprojectadevspain1"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

moved {
  from = azurerm_resource_group.rg-projectA-dev-spain-001
  to   = module.resource_group.azurerm_resource_group.this
}
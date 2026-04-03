terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.67.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
  subscription_id = "6e754979-ca8c-46d5-943f-3a83ac43751f"
}

resource "azurerm_resource_group" "rg" {
  name = "TerraformResourceGroup"
  location = "Spain Central"
}
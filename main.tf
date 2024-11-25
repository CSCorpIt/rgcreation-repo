terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }


  backend "azurerm" {
    key                  = "terra-state"
    resource_group_name  = "DefaultResourceGroup-EUS"
    storage_account_name = "terraformstagh"
    container_name       = "terradev"
  }

}


provider "azurerm" {
  features {}
}

locals {
  solution_name       = var.solution_name
  region              = var.region
  environment         = var.environment
  vnet_name           = var.vnet_name
  vnet_rg             = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}
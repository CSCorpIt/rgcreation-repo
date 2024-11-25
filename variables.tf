variable "solution_name" {
  description = "The name of the solution or project."
  type        = string
}

variable "region" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "eastus2"
}

variable "environment" {
  description = "The deployment environment (e.g., dev, test, prod)."
  type        = string
  default     = "dev"
}

variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
  default     = "oddacoreeus2devvnet"
}

variable "vnet_rg" {
  description = "The resource group name for the virtual network."
  type        = string
  default     = "ODDACORE-NETWORK-EUS2-DEV-RG"
}

variable "resource_group_name" {
  description = "The resource group name for the deployment."
  type        = string
}

variable "azurerm_resource_group_name" {
  description = "The Terraform backend state resource group"
  type        = string
  default     = "ODDA-TFSTATE-DEV-RG"
}

variable "azurerm_key" {
  description = "The Terraform backend state key."
  type        = string
  default     = "snackingnextgen-dev-comp-eastus2.tfstate"
}

variable "azurerm_storage_account_name" {
  description = "The name of the Azure storage account for the backend."
  type        = string
  default     = "oddatfstateeus2devsa"
}

variable "azurerm_container_name" {
  description = "The name of the storage container for the backend."
  type        = string
  default     = "resource-tfstate"
}
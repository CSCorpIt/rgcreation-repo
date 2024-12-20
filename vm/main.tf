terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }


  backend "azurerm" {
    key                  = "terra-state"
    resource_group_name  = "DefaultResourceGroup-EUS"
    storage_account_name = "terraformstagh"
    container_name       = "terradev"
    use_oidc             = true                                   # Can also be set via `ARM_USE_OIDC` environment variable.
    client_id            = "f9ae38b8-7b03-4817-9039-39cb4774621d" # Can also be set via `ARM_CLIENT_ID` environment variable.
    subscription_id      = "19c90abf-d616-4f8c-b887-f0490119b05a" # Can also be set via `ARM_SUBSCRIPTION_ID` environment variable.
    tenant_id            = "0dcd7d6a-ba5c-44b2-8858-b89a508cc2fd" # Can also be set via `ARM_TENANT_ID` environment variable.
  }

}



provider "azurerm" {

  subscription_id = var.subID
  client_id       = var.clientID
  tenant_id       = var.tenantID
  use_oidc        = true

  features {}

}

resource "azurerm_resource_group" "resource_group" {
  name     = "${var.solutionName}-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.solutionName}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}


resource "azurerm_public_ip" "public_ip" {
  name                = "vm_public_ip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Static"
}



resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}


resource "azurerm_subnet_network_security_group_association" "nsg-ass" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.solutionName}-vm-nic"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.solutionName}-vm"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  size                = var.vmSize
  admin_username      = "cspower"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_ssh_key {
    username   = "cspower"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}

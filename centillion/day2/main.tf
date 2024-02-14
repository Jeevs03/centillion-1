terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sample" {
  name     = "example-resources"
  location = "West Europe"

  tags = {
    "terraform" = "terraform"
  }
}

resource "azurerm_storage_account" "adls" {
  name                     = "jeevanthsaccount"  # Choose a unique name here
  resource_group_name      = azurerm_resource_group.sample.name
  location                 = azurerm_resource_group.sample.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "mytg-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.sample.location
  resource_group_name = azurerm_resource_group.sample.name

  tags = {
    "terraform" = "terraform"
  }
}

resource "azurerm_subnet" "example" {
  name                 = "mytg-subnet"
  virtual_network_name = azurerm_virtual_network.example.name
  resource_group_name  = azurerm_resource_group.sample.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.example.id
  network_security_group_id = azurerm_network_security_group.example.id
}

resource "azurerm_network_security_group" "example" {
  name                = "mytg-nsg"
  location            = azurerm_resource_group.sample.location
  resource_group_name = azurerm_resource_group.sample.name

  security_rule {
    name                       = "Allow_HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    "environment" = "Production"
  }
}

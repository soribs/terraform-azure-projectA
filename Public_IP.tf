resource "azurerm_public_ip" "public_IP" {
  name                = var.public_IP
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "bastion-public-IP" {
  name                = "bas-pip"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "NatGateway-public-IP" {
  name                = "Nat-Gateway-PIP"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
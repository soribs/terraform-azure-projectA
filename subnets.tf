resource "azurerm_subnet" "snet-subnet" {
  name                 = var.subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-projectA-dev-spain-001.name
  address_prefixes     = [var.address_prefixes[0]]
}

resource "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg-projectA-dev-spain-001.name
  virtual_network_name = azurerm_virtual_network.vnet-projectA-dev-spain-001.name
  address_prefixes     = [var.address_prefixes[1]]
}
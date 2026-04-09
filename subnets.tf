resource "azurerm_subnet" "snet-subnet" {
  name                 = var.subnet
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet-projectA-dev-spain-001.name
  address_prefixes     = var.address_prefixes
}
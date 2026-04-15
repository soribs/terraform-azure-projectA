resource "azurerm_virtual_network" "vnet-projectA-dev-spain-001" {
  name                = var.virtual_network_name
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  address_space       = var.address_space
  dns_servers         = []
}
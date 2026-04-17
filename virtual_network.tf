resource "azurerm_virtual_network" "vnet-projectA-dev-spain-001" {
  name                = var.virtual_network_name
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  address_space       = var.address_space
  dns_servers         = []
}
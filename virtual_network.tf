resource "azurerm_virtual_network" "vnet-projectA-dev-spain-001" {
  name                = var.virtual_network_name
<<<<<<< HEAD
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
=======
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
>>>>>>> 6f056d73d98810ad6938c3120a0dd91a558f66b7
  address_space       = var.address_space
  dns_servers         = []
}
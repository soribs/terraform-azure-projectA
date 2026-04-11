resource "azurerm_public_ip" "public_IP" {
  name                = var.public_IP
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
  allocation_method   = "Static"
}
 
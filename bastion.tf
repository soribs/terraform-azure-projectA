resource "azurerm_bastion_host" "bastion-projectA-dev-spain-001" {
  name                = "bs-linux"
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name

  ip_configuration {
    name                 = "configuration-IP-adress"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion-public-IP.id
  }
}
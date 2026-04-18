resource "azurerm_bastion_host" "bastion-projectA-prod-spain-001" {
  name                = "bs-linux"
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  ip_configuration {
    name                 = "configuration-IP-adress"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion-public-IP.id
  }
}
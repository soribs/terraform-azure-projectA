resource "azurerm_nat_gateway" "NatGateway" {
  name                = "NatGateway"
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "NatGateway-pip-association" {
  nat_gateway_id       = azurerm_nat_gateway.NatGateway.id
  public_ip_address_id = azurerm_public_ip.NatGateway-public-IP.id
}

resource "azurerm_subnet_nat_gateway_association" "NatGateway-vmsubnet-association" {
  subnet_id      = azurerm_subnet.snet-subnet.id # <- VM Subnet
  nat_gateway_id = azurerm_nat_gateway.NatGateway.id
}

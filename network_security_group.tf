resource "azurerm_network_security_group" "security-rule-projectA-dev-spain-001" {
  name                = var.nsg
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  security_rule {
    name                       = var.security_rule_name
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.tags.environment
  }
}

resource "azurerm_subnet_network_security_group_association" "network-security-group-association-dev-spain-001" {
  subnet_id                 = azurerm_subnet.snet-subnet.id
  network_security_group_id = azurerm_network_security_group.security-rule-projectA-dev-spain-001.id
}
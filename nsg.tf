resource "azurerm_network_security_group" "nsg" {
  name                = "linuxvmnsg-projectA-dev-spain-001"
<<<<<<< HEAD
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
=======
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
>>>>>>> 6f056d73d98810ad6938c3120a0dd91a558f66b7

  tags = local.common_tags

  dynamic "security_rule" {
    for_each = var.nsg_rules
    iterator = rule

    content {
      name                       = rule.key
      priority                   = rule.value.priority
      direction                  = rule.value.direction
      access                     = rule.value.access
      protocol                   = rule.value.protocol
      source_port_range          = rule.value.source_port_range
      destination_port_range     = rule.value.destination_port_range
      source_address_prefix      = rule.value.source_address_prefix
      destination_address_prefix = rule.value.destination_address_prefix
    }
  }
}
resource "azurerm_resource_group" "rg-projectA-dev-spain-001" {
  name     = var.resource_group_name
  location = var.location_name

  tags = local.common_tags
}
resource "azurerm_storage_account" "storage-account" {
  for_each                 = var.storage_account_name
  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg-projectA-dev-spain-001.name
  location                 = azurerm_resource_group.rg-projectA-dev-spain-001.location
  account_tier             = var.is_production ? "Premium" : "Standard"
  account_replication_type = each.value.replication

  tags = local.common_tags
}

resource "azurerm_storage_container" "container" {
  count              = var.is_production ? 1 : 0
  name               = "syslog"
  storage_account_id = azurerm_storage_account.storage-account["stprojectadevspain1"].id
}
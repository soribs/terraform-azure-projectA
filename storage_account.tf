resource "azurerm_storage_account" "storage-account" {
  name                     = "stprojectadevspain"
  resource_group_name      = azurerm_resource_group.rg-projectA-dev-spain-001.name
  location                 = azurerm_resource_group.rg-projectA-dev-spain-001.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "container" {
  name               = "syslog"
  storage_account_id = azurerm_storage_account.storage-account.id
}

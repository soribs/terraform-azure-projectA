resource "azurerm_user_assigned_identity" "identity" {
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  name                = "uai-projectA-dev-spain-001"
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
}

resource "azurerm_role_assignment" "ra-storage-blob-contributor" {
  scope                = azurerm_storage_account.storage-account["stprojectadevspain1"].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_role_assignment" "ra-monitoring-contributor" {
  scope                = azurerm_linux_virtual_machine.vm-linux-dev-spain-001.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}
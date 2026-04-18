resource "azurerm_user_assigned_identity" "identity" {
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  name                = "uai-projectA-prod-spain-001"
}

resource "azurerm_role_assignment" "ra-storage-blob-contributor" {
  scope                = azurerm_storage_account.storage-account["stprojectaprodspain1"].id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}

resource "azurerm_role_assignment" "ra-monitoring-contributor" {
  scope                = azurerm_linux_virtual_machine.vm-linux-prod-spain-001.id
  role_definition_name = "Monitoring Contributor"
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
}
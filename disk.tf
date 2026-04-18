resource "azurerm_managed_disk" "data-disk-1" {
  name                 = "data-disk-1"
  location             = module.resource_group.resource_group_location
  resource_group_name  = module.resource_group.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "10"
}

resource "azurerm_managed_disk" "data-disk-2" {
  name                 = "data-disk-2"
  location             = module.resource_group.resource_group_location
  resource_group_name  = module.resource_group.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "20"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data-disk-1" {
  managed_disk_id    = azurerm_managed_disk.data-disk-1.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm-linux-prod-spain-001.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "data-disk-2" {
  managed_disk_id    = azurerm_managed_disk.data-disk-2.id
  virtual_machine_id = azurerm_linux_virtual_machine.vm-linux-prod-spain-001.id
  lun                = "20"
  caching            = "ReadWrite"
}
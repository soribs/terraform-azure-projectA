
resource "azurerm_network_interface" "vm-linux-nic-prod-spain-001" {
  name                = var.network_interface
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-subnet.id
    private_ip_address_allocation = var.vm_config.private_ip_address_allocation
    # public_ip_address_id          = azurerm_public_ip.public_IP.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-linux-prod-spain-001" {
  name                = var.linux_vm
  location            = module.resource_group.resource_group_location
  resource_group_name = module.resource_group.resource_group_name
  size                = var.vm-size
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.vm-linux-nic-prod-spain-001.id,
  ]

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/admin_ssh.pub")
  }

  os_disk {
    caching              = var.os_disk["caching"]
    storage_account_type = var.os_disk["storage_account_type"]
  }

  source_image_reference {
    publisher = var.source_image_reference["publisher"]
    offer     = var.source_image_reference["offer"]
    sku       = var.source_image_reference["sku"]
    version   = var.source_image_reference["version"]
  }
}

resource "azurerm_virtual_machine_extension" "linux-ama-agent" {
  name                       = var.vm_config.name
  virtual_machine_id         = azurerm_linux_virtual_machine.vm-linux-prod-spain-001.id
  publisher                  = var.vm_config.publisher
  type                       = var.vm_config.type
  type_handler_version       = var.vm_config.type_handler_version
  auto_upgrade_minor_version = var.vm_config.auto_upgrade_minor_version

  depends_on = [
    azurerm_role_assignment.ra-storage-blob-contributor,
    azurerm_role_assignment.ra-monitoring-contributor,
  ]
  # it going to first create the permission of the role assigment before
  # the agent is installed and try to connect to the storage account 

}
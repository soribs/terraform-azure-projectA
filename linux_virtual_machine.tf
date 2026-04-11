
resource "azurerm_network_interface" "vm-linux-nic-dev-spain-001" {
  name                = var.network_interface
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_IP.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-linux-dev-spain-001" {
  name                = var.linux_vm
  resource_group_name = azurerm_resource_group.rg-projectA-dev-spain-001.name
  location            = azurerm_resource_group.rg-projectA-dev-spain-001.location
  size                = var.vm-size
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.vm-linux-nic-dev-spain-001.id,
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
  name                       = "Linux-agent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm-linux-dev-spain-001.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

   depends_on = [
    azurerm_role_assignment.ra-storage-blob-contributor,
    azurerm_role_assignment.ra-monitoring-contributor,
  ]
  # it going to first create the permission of the role assigment before
  # the agent is installed and try to connect to the storage account 

}
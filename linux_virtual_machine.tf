
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
  size                = "Standard_D2s_v3"
  admin_username      = var.username
  network_interface_ids = [
    azurerm_network_interface.vm-linux-nic-dev-spain-001.id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/admin_ssh.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.source_image_reference["publisher"]
    offer     = var.source_image_reference["offer"]
    sku       = var.source_image_reference["sku"]
    version   = var.source_image_reference["version"]
  }
}
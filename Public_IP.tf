resource "azurerm_public_ip" "public_IP" {
 name = var.public_IP
 location = var.location_name
 resource_group_name = var.resource_group_name
 allocation_method = "Static"
}
 
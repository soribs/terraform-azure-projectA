variable "resource_group_name" {
  description = "(Required) The Name which should be used for this Resource Group. Changing this forces a new Resource Group to be created."
  type        = string
  default     = "rg-projectA-dev-spain-001"
}

variable "virtual_network_name" {
  description = "(Required) The Name of the Virtual Network"
  type        = string
}

variable "location_name" {
  description = " (Required) The Azure Region where the Resource Group should exist. Changing this forces a new Resource Group to be created."
  type        = string
  default     = "Spain central"
}

variable "number" {
  type    = number
  default = 6.2
}

variable "boolean" {
  type    = bool
  default = true
}

variable "address_prefixes" {
  description = "(Required) The address prefixes to use for the subnet"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
}

variable "tags" {
  description = " (Optional) A mapping of tags which should be assigned to the Resource Group."
  type        = map(string)
  default = {
    project     = "projectA"
    environment = "dev"
  }
}

variable "address_space" {
  description = "(Optional) The address space that is used the virtual network. You can supply more than one address space"
  type        = set(string)
  default     = ["10.0.0.0/16"]
}

variable "dns_servers" {
  description = "(Optional) List of IP addresses of DNS servers"
  type        = set(string)
  default     = []
}

variable "subnet" {
  description = " (Optional) Can be specified multiple times to define multiple subnets. Each subnet block supports fields documented below."
  type        = string
  default     = "snet-subnet"
}

variable "linux_vm" {
  description = "(Required) The Name of the Linux Virtual Machine"
  type        = string
  default     = "vm-linux-dev-spain-001"
}

variable "network_interface" {
  type    = string
  default = "nic-projectA"
}

variable "storage_account_name" {
  description = "Name of the storage account"
  type = map(object({
    tier        = string
    replication = string
  }))
  default = {
    "stprojectadevspain1" = {
      tier        = "Standard"
      replication = "LRS"
    },
    "stprojectadevspain2" = {
      tier        = "Standard"
      replication = "LRS"
    },
    "stprojectadevspain3" = {
      tier        = "Standard"
      replication = "LRS"
    },
  }
}
variable "public_IP" {
  type    = string
  default = "public-IP-spain-001"
}

variable "nsg" {
  type    = string
  default = "NSG-dev-spain-001"
}

variable "security_rule_name" {
  type    = string
  default = "security-rule-projectA-dev-spain-001"
}

variable "subscription_id" {
  type        = string
  description = "L'ID de ma souscription Azure"
}

variable "username" {
  type        = string
  description = "Username Unbuntu"
}

variable "source_image_reference" {
  type = map(string)
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

}

variable "os_disk" {
  type = map(string)
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

}

variable "vm-size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "vm_config" {
  type = object({
    name                          = string
    type                          = string
    publisher                     = string
    type_handler_version          = string
    auto_upgrade_minor_version    = bool
    private_ip_address_allocation = string
  })
  default = {
    private_ip_address_allocation = "Dynamic"
    name                          = "Linux-agent"
    type                          = "AzureMonitorLinuxAgent"
    publisher                     = "Microsoft.Azure.Monitor"
    type_handler_version          = "1.0"
    auto_upgrade_minor_version    = true
  }

}

variable "is_production" {
  description = "if true, deploys production tier storage account"
  type        = bool
  default     = false
}

variable "nsg_rules" {
  type = map(object({
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = {
    "AllowSSH" = {
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    "AllowHTTP" = {
      priority                   = 200
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "80"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    },
    "AllowHTTPS" = {
      priority                   = 300
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
  }
}
}
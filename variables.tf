variable "resource_group_name" {
  description = "the name of the ressource group"
  type        = string
  default     = "rg-projectA-dev-spain-001"
}

variable "virtual_network_name" {
  description = "the name of the Vnet"
  type        = string
}

variable "location_name" {
  description = "the name of the location"
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
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "tags" {
  type = map(string)
  default = {
    project     = "projectA"
    environment = "dev"
  }
}

variable "address_space" {
  type    = set(string)
  default = ["10.0.0.0/16"]
}

variable "dns_servers" {
  type    = set(string)
  default = ["10.0.0.4", "10.0.0.5"]
}

variable "subnet" {
  type    = string
  default = "snet-subnet"
}

variable "linux_vm" {
  type    = string
  default = "vm-linux-dev-spain-001"
}

variable "network_interface" {
  type    = string
  default = "nic-projectA"

}
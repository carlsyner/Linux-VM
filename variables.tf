variable "location" {
  description = "Location of the network"
  default     = "uksouth"
}

variable "username" {
  description = "Username for Virtual Machines"
  default     = "azureadmin"
}

variable "password" {
  description = "Password for Virtual Machines"
  default     = "Password1234!"
}

variable "vmsize" {
  description = "Size of the VMs"
  default     = "Standard_DS1_v2"
}
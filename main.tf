provider "azurerm" {
     version = "~>2.0"
    features {}
}

## Resource Group 

resource "azurerm_resource_group" "terraform-web-rg" {
  name     = "Terraform-Web-RG"
  location = var.location
}

## Virtual Network 

resource "azurerm_virtual_network" "web-vnet" {
  name                = "web-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.terraform-web-rg.name
  address_space       = ["10.10.0.0/16"]
}

## Subnets 

resource "azurerm_subnet" "web" {
  name                 = "web"
  resource_group_name  = azurerm_resource_group.terraform-web-rg.name
  virtual_network_name = azurerm_virtual_network.web-vnet.name
  address_prefixes       = ["10.10.0.0/24"]
}

## Create Public IPs

resource "azurerm_public_ip" "az-web-pip" {
    name                 = "az-web-pip"
    location            = var.location
    resource_group_name = azurerm_resource_group.terraform-web-rg.name
    allocation_method   = "Static"
}

## Network interface 

resource "azurerm_network_interface" "az-web-nic" {
  name                 = "az-web-nic"
  location             = var.location
  resource_group_name  = azurerm_resource_group.terraform-web-rg.name
 
  ip_configuration {
    name                          = "az-web-nic"
    subnet_id                     = azurerm_subnet.web.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.az-web-pip.id
  }

}

## Network Security Group anmd rules

resource "azurerm_network_security_group" "az-web-nsg" {
    name                = "az-web-nsg"
    location            = var.location
    resource_group_name = azurerm_resource_group.terraform-web-rg.name

    security_rule {
        name                       = "Allow_SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
      source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
        security_rule {
        name                       = "Allow_HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
      source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "web-nsg-association" {
  subnet_id                 = azurerm_subnet.web.id
  network_security_group_id = azurerm_network_security_group.az-web-nsg.id
}

## Virtual Machine

resource "azurerm_virtual_machine" "az-web-vm" {
  name                  = "az-web-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.terraform-web-rg.name
  network_interface_ids = [azurerm_network_interface.az-web-nic.id]
  vm_size               = var.vmsize

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "az-web-vm"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "az-web-vm"
    admin_username = var.username
    admin_password = var.password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

}






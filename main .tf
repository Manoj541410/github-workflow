provider "azurerm" {
  features {}
  
}

resource "azurerm_resource_group" "testing-rg" {
  name     = "testing-resources"
  location = "East US"
}


resource "azurerm_virtual_network" "testing-vnet" {
  name                = "testing-vnet" 
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.testing-rg.location
  resource_group_name = azurerm_resource_group.testing-rg.name
}


resource "azurerm_subnet" "testing-subnet" {
  name                 = "testing-subnet"
  resource_group_name  = azurerm_resource_group.testing-rg.name
  virtual_network_name = azurerm_virtual_network.testing-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "testing-public-ip" {
  name                = "testing-public-ip"
  location            = azurerm_resource_group.testing-rg.location
  resource_group_name = azurerm_resource_group.testing-rg.name
  allocation_method   = "Dynamic"
}


resource "azurerm_network_interface" "testing-nic" {
  name                = "testing-nic"
  location            = azurerm_resource_group.testing-rg.location
  resource_group_name = azurerm_resource_group.testing-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.testing-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.testing-public-ip.id
  }
}

# Create a virtual machine
resource "azurerm_windows_virtual_machine" "testing-vm" {
  name                = "testing-vm"
  resource_group_name = azurerm_resource_group.testing-rg.name
  location            = azurerm_resource_group.testing-rg.location
  size                = "Standard_B2s"
  admin_username      = "Administrator1"
  admin_password      = "Password@123"

  network_interface_ids = [
    azurerm_network_interface.testing-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

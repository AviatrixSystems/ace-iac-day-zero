# Spoke Ubuntu VM 2

locals {
  bu2_app_user_data = <<EOF
#!/bin/bash
sudo hostnamectl set-hostname "BU2-App"
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sudo echo 'ubuntu:${var.ace_password}' | /usr/sbin/chpasswd
sudo apt update -y
sudo apt upgrade -y
sudo apt-get -y install traceroute unzip build-essential git gcc hping3 apache2 net-tools
sudo apt autoremove
sudo /etc/init.d/ssh restart
EOF
}

resource "azurerm_network_interface" "main" {
  name                = "${var.azure_spoke2_name}-nic1"
  resource_group_name = module.azure_spoke_2.vpc.resource_group
  location            = var.azure_spoke2_region
  ip_configuration {
    name                          = module.azure_spoke_2.vpc.private_subnets[0].name
    subnet_id                     = module.azure_spoke_2.vpc.private_subnets[0].subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "spoke2-app" {
  name                = "spoke2-app"
  resource_group_name = module.azure_spoke_2.vpc.resource_group
  location            = var.azure_spoke2_region
}

resource "azurerm_network_security_rule" "http" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "http"
  priority                    = 100
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "80"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_2.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke2-app.name
}

resource "azurerm_network_security_rule" "ssh" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "ssh"
  priority                    = 110
  protocol                    = "Tcp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "22"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_2.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke2-app.name
}

resource "azurerm_network_security_rule" "icmp" {
  access                      = "Allow"
  direction                   = "Inbound"
  name                        = "icmp"
  priority                    = 120
  protocol                    = "Icmp"
  source_port_range           = "*"
  source_address_prefix       = "*"
  destination_port_range      = "*"
  destination_address_prefix  = "*"
  resource_group_name         = module.azure_spoke_2.vpc.resource_group
  network_security_group_name = azurerm_network_security_group.spoke2-app.name
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.spoke2-app.id
}

resource "azurerm_linux_virtual_machine" "azure_spoke2_vm" {
  name                            = "${var.azure_spoke2_name}-app"
  resource_group_name             = module.azure_spoke_2.vpc.resource_group
  location                        = var.azure_spoke2_region
  size                            = var.azure_test_instance_size
  admin_username                  = "ubuntu"
  admin_password                  = var.ace_password
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  # source_image_reference {
  #   publisher = "canonical"
  #   offer     = "0001-com-ubuntu-server-focal"
  #   version   = "latest"
  # }
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  custom_data = base64encode(local.bu2_app_user_data)
}

output "azure_spoke2_app_private_ip" {
  value = azurerm_linux_virtual_machine.azure_spoke2_vm.private_ip_address
}

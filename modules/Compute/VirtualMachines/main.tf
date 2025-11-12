resource "azurerm_linux_virtual_machine" "linuxvm" {
    count = var.vm_count
  name                = "${var.resource_prefix}Linuxvm0${count.index + 1}"
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password = "Azure@1234"
  // Set to false to enable password authentication
  disable_password_authentication = false
  
  custom_data = base64encode(data.local_file.cloudinit.content)
  // reference to virtual network interface ids variable taken from output of network interface module (inter module communication)
  network_interface_ids = [
    var.virtual_network_interface_ids[count.index]
  ]
 

  

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

data "local_file" "cloudinit" {
  filename = "./modules/Compute/VirtualMachines/cloudinit.yml"
}
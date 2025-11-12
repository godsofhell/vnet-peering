//will wait for around 180 seconds to let nginx install after that we can copy and paste the data on the nginx server else it will give error
resource "time_sleep" "wait_180_seconds"{
  depends_on = [azurerm_linux_virtual_machine.linuxvm]
  create_duration = "180s"
}

//contains the content and the destination of the added files
resource "null_resource" "addfiles" {
    count = var.vm_count
provisioner "file" {
  content      = "<h1> This is the webserver  ${azurerm_linux_virtual_machine.linuxvm[count.index].computer_name}</h1>"
  destination = "/home/adminuser/Default.html"

  connection {
    type     = "ssh"
    user     = "adminuser"
    password = "Azure@1234"
    host     = var.virtual_machine_public_ip_addresses[count.index]
  }
}

provisioner "remote-exec" { 
    connection {
      type     = "ssh"
    user     = "adminuser"
    password = "Azure@1234"
    host     = var.virtual_machine_public_ip_addresses[count.index]
    }
    inline = ["sudo mv /home/adminuser/Default.html /var/www/html/Default.html"]
}
//depends_on = [azurerm_network_security_group.network_security_group]
depends_on = [time_sleep.wait_180_seconds]
}
resource "azurerm_virtual_network_peering" "peeringconnection" {
  name                      = "${var.source_network_name}_to_${var.destination_network_name}"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.source_network_name
  remote_virtual_network_id = var.destination_network_id
}

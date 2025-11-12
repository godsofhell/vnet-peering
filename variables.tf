variable "resource_group_name" {
    type = string 
    description = "contains the name of resource group "
}
variable "location" {
    type = string 
    description = "contains the location of resource group "
}

variable "network_security_group_rules" {
  type        = list(object(
    {
      priority = number
      destination_port_range = string
    }
  ))
  description = "This variable defines the network security group rules."
}

variable "environment"{
    type = map(object(
        {
            vnet_name = string
            vnet_address_prefix = string
            vm_count = number
            vnet_subnet_count = number
            network_interface_count = number
            public_ip_address_count = number
            //resource_prefix = string
        }
    ))
}
variable "vnet_peering"{
    type = map(object(
        {
            virtual_network_key = string
        destination_vnet_name = string
        }
    ))
}



/*variable "network_interface_private_ip_address" {
    type = list(string)
    description = "this is the private IP Addresses of the network interface attached"
}
variable "virtual_network_id" {
  type = string
  description = "Virtual network id of the VMs"
}*/
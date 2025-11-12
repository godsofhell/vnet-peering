resource_group_name = "app-grp"
location = "UK South"



network_security_group_rules = [ 
    {
        priority = 300
        destination_port_range = "22"
  
},
{
        priority = 310
        destination_port_range = "80"
}
 ]

 environment = {
    app03 = {
        vnet_name = "app03-network"
        vnet_address_prefix = "10.0.0.0/16"
        vm_count = 1
        vnet_subnet_count = 1
        network_interface_count = 1
        public_ip_address_count = 1


    },

    test = {
        vnet_name = "test-network"
        vnet_address_prefix = "10.1.0.0/16"
        vm_count = 1
        vnet_subnet_count = 1
        network_interface_count = 1
        public_ip_address_count = 1
    }
    

 }
 vnet_peering = {
   app03-network = {
    virtual_network_key = "test"
    destination_vnet_name = "test-network"
     
   }
   test-network = {
    virtual_network_key = "app03"
     destination_vnet_name = "app03-network"
   }
 }
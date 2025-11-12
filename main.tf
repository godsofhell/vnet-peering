
//module is used to create a resource group
module "resourcegroup" {
  source              = "./modules/general/resourcegroup"
  resource_group_name = var.resource_group_name
  location            = var.location
}
module "network" {
    source = "./modules/networking/vnet"
    for_each = var.environment
    resource_group_name = module.resourcegroup.resource_group_name
    location            = module.resourcegroup.resource_group_location
    vnet_name           = each.value.vnet_name
    vnet_address_prefix = each.value.vnet_address_prefix
    vnet_subnet_count  = each.value.vnet_subnet_count
    public_ip_address_count = each.value.public_ip_address_count
    network_interface_count = each.value.network_interface_count
    network_security_group_rules = var.network_security_group_rules
    resource_prefix = each.key
    //to ensure that resourcegroup is created before vnet
    depends_on = [ module.resourcegroup ]
}
module "VirtualMachines" {
    source = "./modules/Compute/VirtualMachines"
    for_each = var.environment
    resource_group_name = module.resourcegroup.resource_group_name
    location            = module.resourcegroup.resource_group_location
    vm_count = each.value.vm_count
    virtual_network_interface_ids = module.network[each.key].virtual_network_interface_ids
    virtual_machine_public_ip_addresses = module.network[each.key].public_ip_addresses
    resource_prefix = each.key



}
module "vnetpeering"{
    source = "./modules/networking/vnetpeering"
    for_each = var.vnet_peering
    resource_group_name = module.resourcegroup.resource_group_name
    source_network_name = each.key
    destination_network_name = each.value.destination_vnet_name
    destination_network_id = module.network[each.value.virtual_network_key].virtual_network_id

    depends_on = [module.network]
}
variable "resource_group_name" {
    type = string 
    description = "contains the name of resource group "
}
variable "location" {
    type = string 
    description = "contains the location of resource group "
}
variable "vm_count" {
    type = number
    description = "The number of Virtual Machines to create."
}
variable "virtual_network_interface_ids" {
    type = list(string)
    description = "List of network interface IDs to attach to the virtual machines."
}
variable "virtual_machine_public_ip_addresses" {
    type = list(string)
    description = "List of public ip addresses."
}
variable "resource_prefix"{
    type = string
    description = "adds the name of the resource at the beginning of the other resources to show which resource is part of which key"
}
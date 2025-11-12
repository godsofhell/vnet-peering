
variable "location" {
  type        = string
  description = "The name of the Virtual Network."
}
variable "resource_group_name" {
  type        = string
  description = "The name of the Virtual Network."
}
variable "vnet_name" {
  type        = string
  description = "The name of the Virtual Network."
}
variable "vnet_address_prefix" {
  type        = string
  description = "The address space that is used by the Virtual Network."
}
variable "vnet_subnet_count"{
    type = number
    description = "The number of subnets to create in the Virtual Network."
}
variable "public_ip_address_count" {
  type        = number
  description = "The number of Public IPs to create."
}
variable "network_interface_count" {
  type        = number
  description = "The number of network interfaces to create."
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
variable "resource_prefix"{
  type = string
}
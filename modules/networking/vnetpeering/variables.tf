
variable "resource_group_name" {
  type        = string
  description = "The name of the Virtual Network."
}
variable "source_network_name" {
  type        = string
  description = "The Source of the Virtual Network peering."
}
variable "destination_network_name" {
  type        = string
  description = "The virtual machine it wants to connect with."
}
variable "destination_network_id"{
    type        = string
  description = "The id of the virtual machine it wants to connect with."
}
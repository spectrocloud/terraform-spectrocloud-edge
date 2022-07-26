variable "node_pools" {
  description = "Values for the attributes of the Control Plane Nodes."
  type = list(object({
    name          = string
    labels        = optional(map(string))
    control_plane = bool
    nodes = list(object({
      uid    = string
      labels = optional(map(string))
    }))
  }))
}
variable "node_prefix" {
  type    = string
  default = ""
}
variable "cluster_tags" {
  type        = list(string)
  description = "Tags to be added to the profile.  key:value"
  default     = []
}
variable "name" {
  type        = string
  description = "Name of the cluster to be created."
}
variable "cluster_profiles" {
  description = "Values for the profile(s) to be used for cluster creation."
  type = list(object({
    name = string
    tag  = optional(string)
    packs = optional(list(object({
      name   = string
      tag    = string
      values = optional(string)
      manifest = optional(list(object({
        name    = string
        tag     = string
        content = string
      })))
    })))
  }))
}
variable "cluster_vip" {
  type        = string
  description = "IP Address for Cluster VIP for HA.  Must be unused on on the same layer 2 segment as the node IPs."
}
variable "ssh_keys" {
  type    = string
  default = ""
}
variable "ntp_servers" {
  type    = list(string)
  default = []
}
variable "skip_wait_for_completion" {
  type    = bool
  default = true
}
variable "location" {
  type = object({
    latitude  = optional(number)
    longitude = optional(number)
  })
  default = {
    latitude  = 0
    longitude = 0
  }
  description = "Optional - If used Latitude and Longitude represent the coordinates of the location you wish to assign to the cluster.  https://www.latlong.net/ is one tool that can be used to find this."
}
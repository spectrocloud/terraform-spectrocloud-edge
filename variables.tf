variable "machine_pools" {
  description = "Values for the attributes of the Node Pools. 'edge_host_tags' is used to lookup the Edge Host already registered with Palette."
  type = list(object({
    name                    = string
    additional_labels       = optional(map(string))
    control_plane           = optional(bool)
    control_plane_as_worker = optional(bool)
    taints = optional(list(object({
      effect = string
      key    = string
      value  = string
    })))
    edge_host = list(object({
      host_uid        = string
      host_name       = optional(string)
      nic_name        = optional(string)
      static_ip       = optional(string)
      subnet_mask     = optional(string)
      default_gateway = optional(string)
      dns_servers     = optional(list(string))
      two_node_role   = optional(string)
    }))
  }))

  validation {
    condition = alltrue([for mp in var.machine_pools : alltrue([
      for eh in mp.edge_host : (
        eh.two_node_role == null ||
        eh.two_node_role == "primary" ||
        eh.two_node_role == "secondary"
      )
    ])])

    error_message = "The 'two_node_role' field in 'edge_host' objects must be either 'primary', 'secondary', or not set (null)."
  }
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
  description = "Values for the profile(s) to be used for cluster creation.  For `context` a value of [project tenant system] is expected."
  type = list(object({
    name    = string
    tag     = optional(string)
    context = string # project tenant system
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
  default = []
}

variable "rbac_bindings" {
  description = "RBAC Bindings to be added to the cluster"
  type = list(object({
    rbac_type = string
    namespace = optional(string)
    rbac_role = optional(map(string))
    subjects = optional(list(object({
      name      = string
      rbac_type = string
      namespace = optional(string)
    })))
  }))
  default = []
}
variable "cluster_vip" {
  type        = string
  description = "IP Address for Cluster VIP for HA.  Must be unused on on the same layer 2 segment as the node IPs."
  default     = ""
  validation {
    condition     = var.cluster_vip == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", var.cluster_vip))
    error_message = "Cluster VIP must be a valid IP address."
  }
}
variable "overlay_cidr_range" {
  type        = string
  description = "CIDR range for the overlay network."
  default     = ""
  validation {
    condition     = var.overlay_cidr_range == "" || can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.overlay_cidr_range))
    error_message = "Overlay CIDR range must be a valid CIDR range."
  }
}
variable "ssh_keys" {
  type    = list(string)
  default = []
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

variable "cluster_template" {
  description = "Optional cluster template configuration. Provide the template name and context, and optionally cluster profiles with variables. IDs are looked up automatically."
  type = object({
    name    = string
    context = optional(string, "project") # project or tenant
    cluster_profile = optional(list(object({
      name      = string
      tag       = optional(string)
      context   = optional(string, "project") # project, tenant, or system
      variables = optional(map(string))
    })))
  })
  default = null
}

variable "cluster_timezone" {
  type        = string
  description = "Timezone for the cluster."
  default     = ""
}
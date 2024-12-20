data "spectrocloud_cluster_profile" "this" {
  for_each = {
    for profile in var.cluster_profiles : profile.name => profile
  }
  name    = each.key
  version = each.value["tag"]
  context = each.value["context"]
}

resource "spectrocloud_cluster_edge_native" "this" {
  name            = var.name
  tags            = var.cluster_tags
  skip_completion = var.skip_wait_for_completion

  cloud_config {

    ssh_keys           = var.ssh_keys
    vip                = var.cluster_vip != "" ? var.cluster_vip : null
    overlay_cidr_range = var.overlay_cidr_range != "" ? var.overlay_cidr_range : null
    ntp_servers        = var.ntp_servers
  }
  location_config {
    latitude  = var.location.latitude
    longitude = var.location.longitude
  }
  dynamic "machine_pool" {
    for_each = var.machine_pools
    content {
      name                    = machine_pool.value.name
      control_plane           = machine_pool.value.control_plane
      control_plane_as_worker = machine_pool.value.control_plane_as_worker
      additional_labels       = machine_pool.value.additional_labels

      dynamic "taints" {
        for_each = machine_pool.value.taints != null ? machine_pool.value.taints : []

        content {
          effect = taints.value.effect
          key    = tainst.value.key
          value  = taints.value.value
        }
      }

      dynamic "edge_host" {
        for_each = machine_pool.value.edge_host
        content {
          host_uid        = edge_host.value.host_uid
          host_name       = edge_host.value.host_name
          nic_name        = edge_host.value.nic_name
          static_ip       = edge_host.value.static_ip
          subnet_mask     = edge_host.value.subnet_mask
          default_gateway = edge_host.value.default_gateway
          dns_servers     = edge_host.value.dns_servers
          two_node_role   = edge_host.value.two_node_role

        }
      }
    }
  }
  dynamic "cluster_profile" {
    for_each = var.cluster_profiles
    content {
      id = data.spectrocloud_cluster_profile.this[cluster_profile.value.name].id
      dynamic "pack" {
        for_each = cluster_profile.value.packs == null ? [] : cluster_profile.value.packs
        content {
          name   = pack.value.name
          tag    = pack.value.tag
          values = pack.value.values
        }
      }
    }

  }

  dynamic "cluster_rbac_binding" {
    for_each = var.rbac_bindings
    content {
      type      = cluster_rbac_binding.value.rbac_type
      namespace = cluster_rbac_binding.value.namespace
      role      = cluster_rbac_binding.value.rbac_role

      dynamic "subjects" {
        for_each = cluster_rbac_binding.value.subjects
        content {
          name      = subjects.value.name
          type      = subjects.value.rbac_type
          namespace = subjects.value.namespace
        }
      }
    }
  }

}
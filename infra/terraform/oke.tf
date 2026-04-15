resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = local.target_compartment_id
  kubernetes_version = local.selected_kubernetes_version
  name               = var.cluster_name
  vcn_id             = oci_core_vcn.oke_vcn.id

  endpoint_config {
    is_public_ip_enabled = var.kube_api_endpoint_is_public
    subnet_id            = oci_core_subnet.control_plane_subnet.id
  }

  options {
    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }

    service_lb_subnet_ids = [oci_core_subnet.service_lb_subnet.id]
  }
}

resource "oci_containerengine_node_pool" "bootstrap_pool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = local.target_compartment_id
  kubernetes_version = local.selected_kubernetes_version
  name               = "${var.cluster_name}-bootstrap"
  node_shape         = var.bootstrap_node_shape

  node_config_details {
    size = var.bootstrap_node_count

    placement_configs {
      availability_domain = local.selected_availability_domain
      subnet_id           = oci_core_subnet.workers_subnet.id
    }
  }

  node_shape_config {
    ocpus         = var.bootstrap_node_ocpus
    memory_in_gbs = var.bootstrap_node_memory_gbs
  }

  node_source_details {
    source_type = "IMAGE"
    image_id    = local.selected_node_image_id
  }

  node_metadata = length(trimspace(var.ssh_public_key != null ? var.ssh_public_key : "")) > 0 ? {
    ssh_authorized_keys = var.ssh_public_key
  } : {}

  initial_node_labels {
    key   = "role"
    value = "bootstrap"
  }

  lifecycle {
    ignore_changes = [
      node_config_details[0].size,
    ]

    precondition {
      condition     = local.selected_node_image_id != null
      error_message = "No compatible OKE node image found automatically. Set node_image_id explicitly in terraform.tfvars."
    }
  }
}

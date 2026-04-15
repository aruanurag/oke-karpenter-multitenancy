data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_containerengine_cluster_option" "oke_cluster_options" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "oke_node_pool_options" {
  node_pool_option_id = "all"
  compartment_id      = local.target_compartment_id
}

locals {
  selected_availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  cluster_versions_desc        = reverse(sort(data.oci_containerengine_cluster_option.oke_cluster_options.kubernetes_versions))
  requested_kubernetes_version = var.kubernetes_version != null ? var.kubernetes_version : ""

  image_sources     = [for source in data.oci_containerengine_node_pool_option.oke_node_pool_options.sources : source if source.source_type == "IMAGE"]
  oke_image_sources = [for source in local.image_sources : source if strcontains(lower(source.source_name), "oke")]
  arm_image_sources = [for source in local.oke_image_sources : source if strcontains(lower(source.source_name), "arm")]

  arm_requested_version_sources = [
    for source in local.arm_image_sources : source
    if length(local.requested_kubernetes_version) > 0 && strcontains(source.source_name, local.requested_kubernetes_version)
  ]
  requested_version_sources = [
    for source in local.oke_image_sources : source
    if length(local.requested_kubernetes_version) > 0 && strcontains(source.source_name, local.requested_kubernetes_version)
  ]

  auto_image_source = try(
    local.arm_requested_version_sources[0],
    local.requested_version_sources[0],
    local.arm_image_sources[0],
    local.oke_image_sources[0],
    local.image_sources[0],
    null
  )

  manual_image_source_names = var.node_image_id != null ? [for source in local.image_sources : source.source_name if source.image_id == var.node_image_id] : []
  selected_source_name      = var.node_image_id != null ? try(local.manual_image_source_names[0], null) : try(local.auto_image_source.source_name, null)

  selected_node_image_id = var.node_image_id != null ? var.node_image_id : try(local.auto_image_source.image_id, null)

  # Keep Kubernetes version aligned with chosen image when not explicitly pinned.
  selected_kubernetes_version = coalesce(
    var.kubernetes_version,
    try(regex("v[0-9]+\\.[0-9]+\\.[0-9]+", local.selected_source_name), null),
    local.cluster_versions_desc[0]
  )
}

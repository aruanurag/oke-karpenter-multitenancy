output "cluster_id" {
  description = "OKE cluster OCID"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "target_compartment_id" {
  description = "Effective compartment OCID used for OKE resources"
  value       = local.target_compartment_id
}

output "created_compartment_id" {
  description = "Created compartment OCID (null when create_compartment is false)"
  value       = var.create_compartment ? oci_identity_compartment.oke_compartment[0].id : null
}

output "cluster_name" {
  description = "OKE cluster name"
  value       = oci_containerengine_cluster.oke_cluster.name
}

output "selected_availability_domain" {
  description = "Availability domain selected from the configured region"
  value       = local.selected_availability_domain
}

output "selected_kubernetes_version" {
  description = "Latest OKE Kubernetes version selected from OCI cluster options"
  value       = local.selected_kubernetes_version
}

output "selected_node_image_id" {
  description = "Node image OCID selected automatically (or overridden by node_image_id)"
  value       = local.selected_node_image_id
}

output "selected_node_image_source_name" {
  description = "Node image source name selected automatically (or matching override)"
  value       = local.selected_source_name
}

output "bootstrap_node_pool_id" {
  description = "Bootstrap node pool OCID"
  value       = oci_containerengine_node_pool.bootstrap_pool.id
}

output "workers_subnet_id" {
  description = "Workers subnet OCID"
  value       = oci_core_subnet.workers_subnet.id
}

output "service_lb_subnet_id" {
  description = "Service load balancer subnet OCID"
  value       = oci_core_subnet.service_lb_subnet.id
}

output "service_gateway_target_name" {
  description = "OCI service network target used by the Service Gateway"
  value       = local.oci_service_network_service != null ? local.oci_service_network_service.name : null
}

output "karpenter_dynamic_group_id" {
  description = "Dynamic group OCID"
  value       = oci_identity_dynamic_group.karpenter_dg.id
}

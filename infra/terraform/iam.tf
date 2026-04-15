resource "oci_identity_dynamic_group" "karpenter_dg" {
  compartment_id = var.tenancy_ocid
  name           = var.karpenter_dynamic_group_name
  description    = var.karpenter_dynamic_group_description
  matching_rule  = coalesce(var.karpenter_dynamic_group_matching_rule, "ALL {resource.type = 'cluster', resource.compartment.id = '${local.target_compartment_id}'}")
}

resource "oci_identity_policy" "karpenter_policy" {
  count = length(var.karpenter_policy_statements) > 0 ? 1 : 0

  compartment_id = local.target_compartment_id
  name           = var.karpenter_policy_name
  description    = "Policy scaffold for Karpenter permissions"
  statements     = var.karpenter_policy_statements
}

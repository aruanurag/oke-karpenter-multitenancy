locals {
  compartment_parent_id = length(trimspace(var.parent_compartment_ocid != null ? var.parent_compartment_ocid : "")) > 0 ? var.parent_compartment_ocid : var.tenancy_ocid
  target_compartment_id = var.create_compartment ? oci_identity_compartment.oke_compartment[0].id : var.compartment_ocid
}

resource "oci_identity_compartment" "oke_compartment" {
  count = var.create_compartment ? 1 : 0

  compartment_id = local.compartment_parent_id
  name           = var.new_compartment_name
  description    = var.new_compartment_description
  enable_delete  = false
}

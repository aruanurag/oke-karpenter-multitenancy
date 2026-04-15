resource "oci_core_vcn" "oke_vcn" {
  compartment_id = local.target_compartment_id
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.cluster_name}-vcn"
  dns_label      = "okevcn"
}

resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-igw"
  enabled        = true
}

data "oci_core_services" "all_oci_services" {}

locals {
  oci_service_network_services = [
    for service in data.oci_core_services.all_oci_services.services : service
    if strcontains(lower(service.name), "all")
    && strcontains(lower(service.name), "services in oracle services network")
  ]
  oci_service_network_service = try(local.oci_service_network_services[0], null)
}

resource "oci_core_nat_gateway" "oke_nat" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-nat"
}

resource "oci_core_service_gateway" "oke_sgw" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-sgw"

  services {
    service_id = local.oci_service_network_service.id
  }

  lifecycle {
    precondition {
      condition     = local.oci_service_network_service != null
      error_message = "Could not find 'All <region> Services in Oracle Services Network' service entry in OCI services list."
    }
  }
}

resource "oci_core_route_table" "public_rt" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

resource "oci_core_route_table" "private_rt" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.oke_nat.id
  }

  route_rules {
    destination       = local.oci_service_network_service.cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.oke_sgw.id
  }
}

resource "oci_core_security_list" "control_plane_sl" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-control-plane-sl"

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.worker_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.worker_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = var.worker_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = local.oci_service_network_service.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = var.worker_subnet_cidr

    tcp_options {
      min = 1
      max = 65535
    }
  }

  egress_security_rules {
    protocol    = "1"
    destination = var.worker_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }
}

resource "oci_core_security_list" "workers_sl" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-workers-sl"

  ingress_security_rules {
    protocol = "all"
    source   = var.worker_subnet_cidr
  }

  ingress_security_rules {
    protocol = "1"
    source   = var.control_plane_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.control_plane_subnet_cidr

    tcp_options {
      min = 1
      max = 65535
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = var.worker_subnet_cidr
  }

  egress_security_rules {
    protocol    = "6"
    destination = var.control_plane_subnet_cidr

    tcp_options {
      min = 6443
      max = 6443
    }
  }

  egress_security_rules {
    protocol    = "6"
    destination = var.control_plane_subnet_cidr

    tcp_options {
      min = 12250
      max = 12250
    }
  }

  egress_security_rules {
    protocol    = "1"
    destination = var.control_plane_subnet_cidr

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol         = "6"
    destination      = local.oci_service_network_service.cidr_block
    destination_type = "SERVICE_CIDR_BLOCK"

    tcp_options {
      min = 443
      max = 443
    }
  }

  egress_security_rules {
    protocol    = "1"
    destination = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "service_lb_sl" {
  compartment_id = local.target_compartment_id
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.cluster_name}-service-lb-sl"
}

resource "oci_core_subnet" "control_plane_subnet" {
  compartment_id             = local.target_compartment_id
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.control_plane_subnet_cidr
  display_name               = "${var.cluster_name}-control-plane-subnet"
  dns_label                  = "cp"
  route_table_id             = oci_core_route_table.public_rt.id
  security_list_ids          = [oci_core_security_list.control_plane_sl.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "workers_subnet" {
  compartment_id             = local.target_compartment_id
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.worker_subnet_cidr
  display_name               = "${var.cluster_name}-workers-subnet"
  dns_label                  = "wrk"
  route_table_id             = oci_core_route_table.private_rt.id
  security_list_ids          = [oci_core_security_list.workers_sl.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_subnet" "service_lb_subnet" {
  compartment_id             = local.target_compartment_id
  vcn_id                     = oci_core_vcn.oke_vcn.id
  cidr_block                 = var.service_lb_subnet_cidr
  display_name               = "${var.cluster_name}-service-lb-subnet"
  dns_label                  = "slb"
  route_table_id             = oci_core_route_table.public_rt.id
  security_list_ids          = [oci_core_security_list.service_lb_sl.id]
  prohibit_public_ip_on_vnic = false
}

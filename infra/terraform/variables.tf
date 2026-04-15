variable "tenancy_ocid" {
  description = "OCI tenancy OCID"
  type        = string

  validation {
    condition     = length(trimspace(var.tenancy_ocid)) > 0
    error_message = "Set tenancy_ocid to a non-empty tenancy OCID."
  }
}

variable "compartment_ocid" {
  description = "Compartment OCID where OKE resources are created"
  type        = string
  default     = null

  validation {
    condition     = var.create_compartment || length(trimspace(var.compartment_ocid != null ? var.compartment_ocid : "")) > 0
    error_message = "Set compartment_ocid when create_compartment is false."
  }
}

variable "create_compartment" {
  description = "Create a new compartment for OKE resources"
  type        = bool
  default     = true
}

variable "parent_compartment_ocid" {
  description = "Parent compartment OCID for creating a new compartment; defaults to tenancy OCID"
  type        = string
  default     = null
}

variable "new_compartment_name" {
  description = "Name for the new compartment when create_compartment is true"
  type        = string
  default     = "oke-karpenter"
}

variable "new_compartment_description" {
  description = "Description for the new compartment when create_compartment is true"
  type        = string
  default     = "Compartment for OKE and Karpenter resources"
}

variable "cluster_name" {
  description = "OKE cluster name"
  type        = string
  default     = "oke-karpenter"
}

variable "kubernetes_version" {
  description = "Optional Kubernetes version override; if null, Terraform auto-selects latest compatible version"
  type        = string
  default     = null
}

variable "vcn_cidr" {
  description = "CIDR for the OKE VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "control_plane_subnet_cidr" {
  description = "CIDR for OKE control plane endpoint subnet"
  type        = string
  default     = "10.0.0.0/28"
}

variable "worker_subnet_cidr" {
  description = "CIDR for worker nodes subnet"
  type        = string
  default     = "10.0.10.0/24"
}

variable "service_lb_subnet_cidr" {
  description = "CIDR for Kubernetes service load balancer subnet"
  type        = string
  default     = "10.0.20.0/24"
}

variable "pods_cidr" {
  description = "Pods CIDR for Kubernetes API endpoint options"
  type        = string
  default     = "10.244.0.0/16"
}

variable "services_cidr" {
  description = "Services CIDR for Kubernetes API endpoint options"
  type        = string
  default     = "10.96.0.0/16"
}

variable "bootstrap_node_count" {
  description = "Desired size for the bootstrap managed node pool"
  type        = number
  default     = 1
}

variable "bootstrap_node_shape" {
  description = "Shape for bootstrap node pool; A1 Flex keeps Always Free alignment"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "bootstrap_node_ocpus" {
  description = "OCPUs per bootstrap node"
  type        = number
  default     = 1
}

variable "bootstrap_node_memory_gbs" {
  description = "Memory (GB) per bootstrap node"
  type        = number
  default     = 6
}

variable "node_image_id" {
  description = "Optional OCI image OCID used for worker nodes; if null, Terraform auto-selects one"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  description = "Optional SSH public key injected into worker nodes"
  type        = string
  default     = null
}

variable "kube_api_endpoint_is_public" {
  description = "Whether Kubernetes API endpoint is public"
  type        = bool
  default     = true
}

variable "karpenter_dynamic_group_name" {
  description = "Dynamic group name for Karpenter permissions"
  type        = string
  default     = "oke-karpenter-dg"
}

variable "karpenter_dynamic_group_description" {
  description = "Dynamic group description"
  type        = string
  default     = "Dynamic group for Karpenter control-plane identity"
}

variable "karpenter_dynamic_group_matching_rule" {
  description = "Optional dynamic group matching rule for Karpenter identity; auto-derived if null"
  type        = string
  default     = null
}

variable "karpenter_policy_name" {
  description = "IAM policy name for Karpenter"
  type        = string
  default     = "oke-karpenter-policy"
}

variable "karpenter_policy_statements" {
  description = "Optional policy statements required by Karpenter in your tenancy"
  type        = list(string)
  default     = []
}

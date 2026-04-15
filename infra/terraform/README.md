# Epic 1 Terraform Bootstrap (OCI + OKE)

This folder bootstraps Epic 1:
- VCN, subnets, route tables, security lists
- OKE cluster
- One managed bootstrap node pool on Always Free A1 Flex
- IAM dynamic group + policy scaffolding for Karpenter permissions
- Optional compartment creation (or reuse existing compartment)
- Separate worker and service LB subnets (required by OKE)

## Usage

1. Copy and fill values:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
2. Initialize and validate:
   ```bash
   terraform init
   terraform fmt -recursive
   terraform validate
   ```
3. Plan/apply:
   ```bash
   terraform plan
   terraform apply
   ```

## Compartment Modes

- Reuse existing compartment: set `create_compartment = false` and provide `compartment_ocid`.
- Create new compartment: set `create_compartment = true`; optionally set `parent_compartment_ocid`, `new_compartment_name`, and `new_compartment_description`.

## Notes
- Replace placeholder IAM matching rule/policy statements with the exact Oracle-recommended Karpenter permissions for your tenancy.
- Validate that chosen A1 shape values remain within Always Free limits for your account and region.
- Availability domain is auto-selected from the configured region (first AD returned by OCI).
- Kubernetes version is auto-selected as the latest version returned by OCI cluster options.
- Node image is auto-selected from OKE node pool options; set `node_image_id` only if you want to override.
- Service Gateway now targets "All <region> Services in Oracle Services Network" explicitly (instead of relying on list order).

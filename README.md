# OKE Karpenter Platform Repo

This repository now has two focused parts:

1. `karpenter/`
   - Deploy Karpenter with `values.yaml`
   - Includes practical troubleshooting from real deployment/testing

2. `tenant-onboarding/`
   - Helm-based per-tenant onboarding workflow
   - Includes examples for multiple tenant installs

## Prerequisites

- Existing OKE cluster
- `kubectl`, `helm`, and OCI CLI configured
- Cluster access with permissions to install CRDs, NodePools, and namespace policies

OKE quick-create entrypoint:
- https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm

## Start Here

- Karpenter deployment guide: `karpenter/README.md`
- Tenant onboarding guide: `tenant-onboarding/README.md`

# OKE Karpenter Platform Repo

This repository has two main parts:

1. `karpenter/`
- Mode-aware deployment guidance for Karpenter on OKE.
- Covers both networking modes: VCN-native and Flannel.
- Includes values files, NodeClass/NodePool examples, scripts, and troubleshooting.

2. `tenant-onboarding/`
- Helm-based per-tenant onboarding workflow.
- Creates namespace, quota/limits, dedicated NodePool, and optional sample services.
- This is the primary flow for regular tenant onboarding.

## Prerequisites

- Existing OKE cluster
- `kubectl`, `helm`, and OCI CLI configured
- Cluster access with permissions to install CRDs, NodePools, NodeClasses, and namespace policies

References:
- OKE Quick Cluster: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm
- Karpenter IAM: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/conteng-kpo.htm#conteng-kpo-iam

## Start Here

- Karpenter guide: `karpenter/README.md`
- Networking mode decision guide: `docs/networking-modes.md`
- Step-by-step VCN-native runbook: `docs/deploy-vcn-native.md`
- Step-by-step Flannel runbook: `docs/deploy-flannel.md`
- Troubleshooting guide: `docs/troubleshooting.md`
- Tenant onboarding guide: `tenant-onboarding/README.md`

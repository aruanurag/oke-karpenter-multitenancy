# Karpenter Deployment

This directory is intentionally minimal:
- `values.yaml`: the Helm values used to deploy Karpenter on OKE.

## Prerequisites

1. An existing OKE cluster.
2. `kubectl` configured to that cluster context.
3. OCI IAM policy and dynamic group permissions for node join.
4. Karpenter OCI Helm chart available (downloaded from your internal artifact/source).

Karpenter IAM setup reference:
- https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/conteng-kpo.htm#conteng-kpo-iam

Quick cluster creation (OKE quick create):
- https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm

## Deploy Karpenter

```bash
CHART_PATH="/path/to/karpenter-provider-oci/chart"

helm upgrade --install karpenter "$CHART_PATH" \
  -n karpenter \
  --create-namespace \
  -f ./karpenter/values.yaml
```

## Verify

```bash
kubectl get pods -n karpenter
kubectl get crd | rg -i 'karpenter|ocinodeclass|nativepodnetwork'
```

## Troubleshooting / Gotchas Found

1. Helm namespace ownership mismatch:
   - Symptom: `ClusterRole ... exists and cannot be imported ... release-namespace must equal karpenter`.
   - Fix: always install/upgrade with `-n karpenter` (not default).

2. Incorrect API server endpoint in values:
   - Symptom: nodes launch but fail registration.
   - Fix: set `settings.apiserverEndpoint` to the **private API server IP only** (no scheme, no port), for example `10.0.0.3`, in `values.yaml`, then redeploy chart.

3. Shape/image/arch mismatch:
   - Symptom: `no image suitable for shape ...`.
   - Fix: ensure NodePool requirements and NodeClass shape/image are compatible (for example E5 + amd64).

4. Missing `secondaryVnicConfigs` in `OCINodeClass`:
   - Symptom: NodeClass/network reconcile failure for native pod networking.
   - Fix: define `spec.networkConfig.secondaryVnicConfigs`.

5. Pod CNI sandbox failures `unable to allocate IP address`:
   - Symptom: pods stuck `ContainerCreating`, `NPN` shows `FailedToCreatePrivateIP`.
   - Root cause: subnet IP exhaustion/fragmentation for flex CIDR allocation.
   - Fix: use larger contiguous pod IP space (secondary CIDR or dedicated larger subnet), then recycle NodeClaims.

6. Pods pending even after networking fixed:
   - Symptom: `Insufficient cpu` and `all available instance types exceed limits for nodepool`.
   - Fix: increase `NodePool.spec.limits.cpu` and verify pod requests/instance shape sizing.

7. Karpenter NodePool visibility:
   - Karpenter `NodePool`/`NodeClaim` are Kubernetes CRDs and do not appear as OKE managed node pools in OCI Console.

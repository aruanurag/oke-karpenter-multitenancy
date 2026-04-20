# Karpenter Deployment (VCN-native + Flannel)

This directory supports deploying Karpenter with either OKE networking mode.

Regular day-2 tenant onboarding should use the Helm flow in `tenant-onboarding/`.
The YAML files in `karpenter/examples/` are reference examples for platform setup/testing.

Step-by-step runbooks:
- VCN-native: `docs/deploy-vcn-native.md`
- Flannel: `docs/deploy-flannel.md`

## Files

- `values/vcn-native.values.yaml`: values for VCN-native mode (`ociVcnIpNative: true`)
- `values/flannel.values.yaml`: values for Flannel mode (`ociVcnIpNative: false`)
- `examples/nodeclass-vcn-native.yaml`: OCINodeClass example for VCN-native
- `examples/nodeclass-flannel.yaml`: OCINodeClass example for Flannel
- `examples/nodepool-example.yaml`: NodePool reference YAML (points to an existing NodeClass)
- `scripts/deploy-karpenter.sh`: helper to deploy per mode
- `scripts/validate-cluster.sh`: basic post-deploy checks
- `scripts/smoke-test.sh`: quick operational checks

## Prerequisites

1. An existing OKE cluster.
2. `kubectl` configured to that cluster context.
3. OCI IAM policy and dynamic group permissions for node join.
4. Karpenter OCI Helm chart available (downloaded from your internal artifact/source).

References:
- Karpenter IAM setup: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/conteng-kpo.htm#conteng-kpo-iam
- OKE Quick Cluster: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm

## Deploy Karpenter

```bash
CHART_PATH="/path/to/karpenter-provider-oci/chart"

# VCN-native mode
./karpenter/scripts/deploy-karpenter.sh vcn-native "$CHART_PATH"

# Flannel mode
./karpenter/scripts/deploy-karpenter.sh flannel "$CHART_PATH"
```

For local/private environment values, use `karpenter/values_local.yaml` (gitignored) as an overlay:

```bash
helm upgrade --install karpenter "$CHART_PATH" \
  -n karpenter \
  --create-namespace \
  -f ./karpenter/values/vcn-native.values.yaml \
  -f ./karpenter/values_local.yaml
```

## Apply NodeClass Example

```bash
# choose one based on cluster networking mode
kubectl apply -f ./karpenter/examples/nodeclass-vcn-native.yaml
# or
kubectl apply -f ./karpenter/examples/nodeclass-flannel.yaml
```

## Apply NodePool Example (Optional Reference)

```bash
# edit <nodeclass_name> in file first
kubectl apply -f ./karpenter/examples/nodepool-example.yaml
```

## Verify

```bash
./karpenter/scripts/validate-cluster.sh
```

## Mode Notes

1. VCN-native mode
- Requires NodeClass `secondaryVnicConfigs`.
- Subnet CIDR sizing/contiguous capacity is critical for pod IP allocation.

2. Flannel mode
- Does not require VCN-native pod IP allocation behavior.
- Useful for simpler bootstrap and validation.

## Troubleshooting / Gotchas Found

1. Helm namespace ownership mismatch:
   - Symptom: `ClusterRole ... exists and cannot be imported ... release-namespace must equal karpenter`.
   - Fix: always install/upgrade with `-n karpenter` (not default).

2. Incorrect API server endpoint in values:
   - Symptom: nodes launch but fail registration.
   - Fix: set `settings.apiserverEndpoint` to the private API server IP only (no scheme, no port), for example `10.0.0.3`, then redeploy.

3. Shape/image/arch mismatch:
   - Symptom: `no image suitable for shape ...`.
   - Fix: ensure NodePool requirements and NodeClass shape/image are compatible.

4. Missing `secondaryVnicConfigs` in `OCINodeClass` (VCN-native):
   - Symptom: NodeClass/network reconcile failure.
   - Fix: define `spec.networkConfig.secondaryVnicConfigs`.

5. Pod CNI sandbox failures `unable to allocate IP address` (VCN-native):
   - Symptom: pods stuck `ContainerCreating`, `NPN` shows `FailedToCreatePrivateIP`.
   - Root cause: subnet IP exhaustion/fragmentation for flex CIDR allocation.
   - Fix: use larger contiguous pod IP space (secondary CIDR or dedicated larger subnet), then recycle NodeClaims.

6. Pods pending even after networking is healthy:
   - Symptom: `Insufficient cpu` and `all available instance types exceed limits for nodepool`.
   - Fix: increase `NodePool.spec.limits.cpu` and verify pod requests/instance shape sizing.

7. Karpenter NodePool visibility:
   - Karpenter `NodePool`/`NodeClaim` are Kubernetes CRDs and do not appear as OKE managed node pools in OCI Console.

## Kubernetes Debug Commands Used

1. Controller health and logs:
```bash
kubectl get pods -n karpenter
kubectl logs -n karpenter deploy/karpenter --tail=200
```

2. NodePools and NodeClaims:
```bash
kubectl get nodepools
kubectl describe nodepool <name>
kubectl get nodeclaims -o wide
kubectl describe nodeclaim <name>
```

3. OCI provider class:
```bash
kubectl get ocinodeclass <name> -o yaml
kubectl describe ocinodeclass <name>
```

4. Node labels/shapes:
```bash
kubectl get nodes -L karpenter.sh/nodepool,oci.oraclecloud.com/instance-shape
```

5. Scheduling failure triage:
```bash
kubectl describe pod -n <ns> <pod>
kubectl get events -n <ns> --sort-by=.metadata.creationTimestamp | tail -n 50
```

6. VCN-native NPN checks:
```bash
kubectl get npn
kubectl describe npn <name>
```

7. System daemon health:
```bash
kubectl get pods -n kube-system -o wide | rg -i 'vcn-native-ip-cni|csi-oci|cni|npn'
```

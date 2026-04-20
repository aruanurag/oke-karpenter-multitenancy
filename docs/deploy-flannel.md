# Deploy Karpenter on OKE (Flannel)

This runbook is for OKE clusters using Flannel overlay networking.

## 1. Prerequisites

1. OKE cluster exists and kubeconfig is configured.
2. Karpenter IAM prerequisites are completed.
3. Karpenter chart path is available locally.

References:
- OKE Quick Cluster: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm
- Karpenter IAM: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/conteng-kpo.htm#conteng-kpo-iam

## 2. Configure Values

Base mode file:
- `karpenter/values/flannel.values.yaml`

Set environment-specific values in local override (recommended):
- `karpenter/values_local.yaml` (gitignored)

Required fields:
- `settings.clusterCompartmentId`
- `settings.vcnCompartmentId`
- `settings.apiserverEndpoint` (private IP only, no scheme/port)
- `settings.ociVcnIpNative: false`

## 3. Deploy Karpenter

```bash
CHART_PATH="/path/to/karpenter-provider-oci/chart"
./karpenter/scripts/deploy-karpenter.sh flannel "$CHART_PATH"
```

## 4. Apply Flannel NodeClass Example

Edit placeholders first, then apply:

```bash
kubectl apply -f ./karpenter/examples/nodeclass-flannel.yaml
```

## 5. Create NodePool (Reference)

Edit `<nodeclass_name>` in `karpenter/examples/nodepool-example.yaml` and apply if needed:

```bash
kubectl apply -f ./karpenter/examples/nodepool-example.yaml
```

For regular tenant onboarding, prefer Helm flow in `tenant-onboarding/`.

## 6. Validate

```bash
./karpenter/scripts/validate-cluster.sh
kubectl get nodes -L karpenter.sh/nodepool,oci.oraclecloud.com/instance-shape
```

## 7. Tenant Onboarding Test Commands

Install tenant-a from example values (creates NodeClass + NodePool from example):

```bash
helm upgrade --install tenant-a ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-a.yaml
```

Install more tenants with sample app replica overrides:

```bash
helm upgrade --install tenant-b ./tenant-onboarding/chart \
  -f ./tenant-onboarding/examples/tenant-b.yaml \
  --set sampleServices.ui.enabled=true \
  --set sampleServices.ui.replicaCount=4 \
  --set sampleServices.integration.enabled=true \
  --set sampleServices.integration.replicaCount=4

helm upgrade --install tenant-c ./tenant-onboarding/chart \
  -f ./tenant-onboarding/examples/tenant-c.yaml \
  --set sampleServices.ui.enabled=true \
  --set sampleServices.ui.replicaCount=6 \
  --set sampleServices.integration.enabled=true \
  --set sampleServices.integration.replicaCount=6

helm upgrade --install tenant-d ./tenant-onboarding/chart \
  -f ./tenant-onboarding/examples/tenant-d.yaml \
  --set sampleServices.ui.enabled=true \
  --set sampleServices.ui.replicaCount=8 \
  --set sampleServices.integration.enabled=true \
  --set sampleServices.integration.replicaCount=8
```

Verify:

```bash
kubectl get nodepools
kubectl get ocinodeclass
kubectl get deploy -A | grep -E 'tenant-(a|b|c|d)|ui|integration'
```

## 8. Flannel-specific Focus

Flannel avoids VCN-native pod IP allocation behavior, so NPN checks are not primary.
Focus on:
- API endpoint correctness
- NodePool limits vs pod requests
- node registration and scheduling events

## 9. Switch from Flannel to VCN-native

1. Deploy with VCN-native mode file:

```bash
./karpenter/scripts/deploy-karpenter.sh vcn-native "$CHART_PATH"
```

2. Use VCN-native NodeClass example:

```bash
kubectl apply -f ./karpenter/examples/nodeclass-vcn-native.yaml
```

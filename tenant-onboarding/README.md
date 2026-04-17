# Tenant Onboarding with Karpenter

This area contains the per-tenant onboarding flow.

## Contents

- `chart/`: Helm chart that creates:
  - tenant namespace
  - tenant quota/limits
  - optional network policy and RBAC binding
  - dedicated Karpenter NodePool
  - optional native ValidatingAdmissionPolicy enforcement
- `examples/`: sample values files for multiple tenants.

## Onboard a Tenant

```bash
helm install tenant-a ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-a.yaml
```

## Upgrade Tenant Capacity

```bash
helm upgrade tenant-a ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-a.yaml
```

## Offboard Tenant

```bash
helm uninstall tenant-a
```

## Deploy Example Tenants

```bash
helm install tenant-a ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-a.yaml
helm install tenant-b ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-b.yaml
helm install tenant-c ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-c.yaml
helm install tenant-d ./tenant-onboarding/chart -f ./tenant-onboarding/examples/tenant-d.yaml
```

## Deploy With Sample Apps (UI + Integration)

For any tenant:

```bash
TENANT=tenant-b

helm upgrade --install "$TENANT" ./tenant-onboarding/chart \
  -f "./tenant-onboarding/examples/${TENANT}.yaml" \
  --set sampleServices.ui.enabled=true \
  --set sampleServices.integration.enabled=true
```

Verify:

```bash
kubectl get deploy,svc,pods -n "$TENANT"
```

## Notes

- NodeClaims are not managed by Helm.
- Karpenter creates/deletes NodeClaims automatically as workloads scale.
- Keep tenant workloads aligned with the chart's taint/label scheduling contract.

# tenant-onboarding Helm chart

Per-tenant install that creates:
- Namespace
- Quota / LimitRange
- Optional NetworkPolicy and tenant RBAC
- Dedicated Karpenter NodePool (no NodeClaims managed directly)
- Optional native ValidatingAdmissionPolicy for scheduling contract enforcement
- Optional sample services (`ui` and `integration`) with tenant-aware scheduling

## Install

```bash
helm install tenant-a ./tenant-onboarding/chart \
  --set tenant.id=tenant-a \
  --set tenant.namespace=tenant-a \
  --set nodePool.nodeClassRef.name=a1-baseline
```

## Upgrade tenant size

```bash
helm upgrade tenant-a ./tenant-onboarding/chart \
  --set tenant.id=tenant-a \
  --set tenant.namespace=tenant-a \
  --set nodePool.limits.cpu=64 \
  --set quota.hard.requests.cpu=64
```

## Uninstall

```bash
helm uninstall tenant-a
```

If the namespace was created by this chart, it will be deleted with uninstall.
Karpenter NodeClaims are owned by Karpenter and will drain/terminate as workloads disappear.

## Notes

- `nodePool.nodeClassRef.name` should usually point to a shared, pre-created `OCINodeClass`.
- Keep `isolation.enabled=true` to stamp tenant label + taint on tenant nodes.
- For strict enforcement, either:
  - enable `admissionPolicy.enabled=true` (native ValidatingAdmissionPolicy), or
  - use Kyverno/Gatekeeper if already standard in your platform.
- To deploy sample apps as part of onboarding, enable:
  - `sampleServices.ui.enabled=true`
  - `sampleServices.integration.enabled=true`

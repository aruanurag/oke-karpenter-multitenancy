# tenant-onboarding Helm chart

Per-tenant install that creates:
- Namespace
- Quota / LimitRange
- Optional NetworkPolicy and tenant RBAC
- Dedicated Karpenter NodePool (no NodeClaims managed directly)
- Optional tenant-specific `OCINodeClass`
- Optional native ValidatingAdmissionPolicy for scheduling contract enforcement
- Optional sample services (`ui` and `integration`) with tenant-aware scheduling

## Install

```bash
helm install tenant-a ./tenant-onboarding/chart \
  -f ./tenant-onboarding/examples/tenant-a.yaml
```

Update placeholder values in `tenant-onboarding/examples/tenant-a.yaml` before install:
- `<node_compartment_ocid>`
- `<node_subnet_ocid>`
- `<oke_image_ocid>`

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

- By default, chart can either reference an existing `OCINodeClass` or create one.
- If you want the chart to create NodeClass too, set:
  - `nodeClass.create=true`
  - `nodeClass.spec={...}` (raw `OCINodeClass.spec`)
- Keep `isolation.enabled=true` to stamp tenant label + taint on tenant nodes.
- For strict enforcement, either:
  - enable `admissionPolicy.enabled=true` (native ValidatingAdmissionPolicy), or
  - use Kyverno/Gatekeeper if already standard in your platform.
- To deploy sample apps as part of onboarding, enable:
  - `sampleServices.ui.enabled=true`
  - `sampleServices.integration.enabled=true`

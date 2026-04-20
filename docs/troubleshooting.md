# Troubleshooting

## Shared Checks

```bash
kubectl get pods -n karpenter
kubectl logs -n karpenter deploy/karpenter --tail=200
kubectl get nodepools
kubectl get nodeclaims -o wide
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 100
```

## VCN-native Common Issues

1. `FailedToCreatePrivateIP` / `unable to allocate IP address`
- Check:
```bash
kubectl get npn
kubectl describe npn <name>
```
- Usually subnet capacity/contiguous CIDR issue.
- Fix by using larger or secondary subnet CIDR and recycling NodeClaims.

2. NodeClass network resolve failures
- Ensure `secondaryVnicConfigs` is present in NodeClass.

## Flannel Common Issues

1. Node launches but does not register
- Verify private API endpoint IP in values (no scheme/port).

2. Pods pending from scheduling limits
- Check NodePool CPU/memory limits and pod requests.

## Useful Commands

```bash
kubectl get nodes -L karpenter.sh/nodepool,oci.oraclecloud.com/instance-shape
kubectl describe nodepool <name>
kubectl describe nodeclaim <name>
kubectl get ocinodeclass -A
```

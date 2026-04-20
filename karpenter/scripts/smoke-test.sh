#!/usr/bin/env bash
set -euo pipefail

kubectl get nodes -L karpenter.sh/nodepool,oci.oraclecloud.com/instance-shape
kubectl get events -A --sort-by=.metadata.creationTimestamp | tail -n 50

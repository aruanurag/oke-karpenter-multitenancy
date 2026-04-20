#!/usr/bin/env bash
set -euo pipefail

kubectl get pods -n karpenter
kubectl get crd | rg -i 'karpenter|ocinodeclass|nativepodnetwork' || true
kubectl get nodepools || true
kubectl get nodeclaims -o wide || true

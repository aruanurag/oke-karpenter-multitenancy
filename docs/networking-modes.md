# OKE Networking Modes for Karpenter

This repo supports two OKE networking models for Karpenter.

## Modes

1. VCN-native pod networking
- `settings.ociVcnIpNative: true`
- Pod IPs are allocated from OCI subnet capacity via NativePodNetwork.
- Requires careful subnet CIDR sizing and contiguous free ranges.

2. Flannel overlay networking
- `settings.ociVcnIpNative: false`
- Pod networking uses overlay; less direct pressure on subnet pod IP allocation behavior.
- Simpler for first-time Karpenter bring-up.

## Quick Decision Guide

1. Choose VCN-native when:
- You need native VCN-level pod routing/IP behavior.
- You can plan subnet ranges and capacity growth up front.

2. Choose Flannel when:
- You want faster setup and simpler troubleshooting.
- You are validating Karpenter behavior before tuning subnet design.

## Karpenter Values Mapping

- VCN-native values: `karpenter/values/vcn-native.values.yaml`
- Flannel values: `karpenter/values/flannel.values.yaml`

## NodeClass Examples

- VCN-native: `karpenter/examples/nodeclass-vcn-native.yaml`
- Flannel: `karpenter/examples/nodeclass-flannel.yaml`

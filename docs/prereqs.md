# Prerequisites

1. OKE cluster already created.
2. `kubectl`, `helm`, and OCI CLI configured.
3. Access to install cluster-scoped resources (CRDs, NodePools, NodeClasses).
4. OCI IAM dynamic group + policies for Karpenter node join.

References:
- OKE Quick Cluster: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/contengcreatingclusterusingoke_topic-Using_the_Console_to_create_a_Quick_Cluster_with_Default_Settings.htm
- Karpenter IAM: https://docs.oracle.com/en-us/iaas/Content/ContEng/Tasks/conteng-kpo.htm#conteng-kpo-iam

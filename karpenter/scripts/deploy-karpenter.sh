#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
CHART_PATH="${2:-}"

if [[ -z "${MODE}" || -z "${CHART_PATH}" ]]; then
  echo "Usage: $0 <vcn-native|flannel> <chart_path>"
  exit 1
fi

case "${MODE}" in
  vcn-native)
    VALUES_FILE="./karpenter/values/vcn-native.values.yaml"
    ;;
  flannel)
    VALUES_FILE="./karpenter/values/flannel.values.yaml"
    ;;
  *)
    echo "Invalid mode: ${MODE}. Use vcn-native or flannel"
    exit 1
    ;;
esac

echo "Deploying Karpenter in mode=${MODE} using ${VALUES_FILE}"
HELM_ARGS=(
  upgrade --install karpenter "${CHART_PATH}"
  -n karpenter
  --create-namespace
  -f "${VALUES_FILE}"
)

if [[ -f "./karpenter/values_local.yaml" ]]; then
  echo "Using local override: ./karpenter/values_local.yaml"
  HELM_ARGS+=(-f "./karpenter/values_local.yaml")
fi

helm "${HELM_ARGS[@]}"

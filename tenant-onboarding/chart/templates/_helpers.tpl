{{- define "tenant-onboarding.name" -}}
{{- default .Chart.Name .Values.tenant.name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tenant-onboarding.namespace" -}}
{{- required "tenant.namespace is required" .Values.tenant.namespace -}}
{{- end -}}

{{- define "tenant-onboarding.tenantId" -}}
{{- required "tenant.id is required" .Values.tenant.id -}}
{{- end -}}

{{- define "tenant-onboarding.nodePoolName" -}}
{{- if .Values.nodePool.nameOverride -}}
{{- .Values.nodePool.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-np" (include "tenant-onboarding.tenantId" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "tenant-onboarding.nodeClassName" -}}
{{- if .Values.nodeClass.nameOverride -}}
{{- .Values.nodeClass.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-nc" (include "tenant-onboarding.tenantId" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "tenant-onboarding.nodeClassRefName" -}}
{{- if .Values.nodeClass.create -}}
{{ include "tenant-onboarding.nodeClassName" . }}
{{- else -}}
{{ .Values.nodePool.nodeClassRef.name }}
{{- end -}}
{{- end -}}

{{- define "tenant-onboarding.nodeLabelValue" -}}
{{- default (include "tenant-onboarding.tenantId" .) .Values.isolation.nodeLabelValue -}}
{{- end -}}

{{- define "tenant-onboarding.taintValue" -}}
{{- default (include "tenant-onboarding.tenantId" .) .Values.isolation.taint.value -}}
{{- end -}}

{{- define "tenant-onboarding.workloadNodeSelector" -}}
{{- if .Values.isolation.enabled }}
nodeSelector:
  {{ .Values.isolation.nodeLabelKey }}: {{ include "tenant-onboarding.nodeLabelValue" . | quote }}
{{- end }}
{{- end -}}

{{- define "tenant-onboarding.workloadTolerations" -}}
{{- if and .Values.isolation.enabled .Values.isolation.taint.enabled }}
tolerations:
  - key: {{ .Values.isolation.taint.key | quote }}
    operator: Equal
    value: {{ include "tenant-onboarding.taintValue" . | quote }}
    effect: {{ .Values.isolation.taint.effect | quote }}
{{- end }}
{{- end -}}

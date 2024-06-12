{{/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *
  *  Name (defaults to "haproxy-ingress") and a fully qualified name
  *  (defaults to "<release>-haproxy-ingress") of controller and a variant with `.Values.defaultBackend.name`
  *  for the default backend.
  *
  *  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  *  If release name contains the chart name, it will be used as a full name.
  *
  */}}
{{- define "haproxy-ingress.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "haproxy-ingress.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define "haproxy-ingress.defaultBackend.name" -}}
  {{- printf "%s-%s" .Chart.Name .Values.defaultBackend.name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "haproxy-ingress.defaultBackend.fullname" -}}
  {{- $name := default .Chart.Name .Values.nameOverride }}
  {{- if contains $name .Release.Name }}
    {{- printf "%s-%s" .Release.Name .Values.defaultBackend.name | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s-%s-%s" .Release.Name $name .Values.defaultBackend.name | trunc 63 | trimSuffix "-" }}
  {{- end }}
{{- end }}


{{/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *
  *  Common and selector labels
  *
  *  We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
  *
  */}}
{{- define "haproxy-ingress.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "haproxy-ingress.labels" -}}
helm.sh/chart: {{ include "haproxy-ingress.chart" . }}
{{ include "haproxy-ingress.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* need to update NOTES.txt whenever update these labels */}}
{{- define "haproxy-ingress.selectorLabels" -}}
app.kubernetes.io/name: {{ include "haproxy-ingress.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "haproxy-ingress.defaultBackend.labels" -}}
helm.sh/chart: {{ include "haproxy-ingress.chart" . }}
{{ include "haproxy-ingress.defaultBackend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "haproxy-ingress.defaultBackend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "haproxy-ingress.defaultBackend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}


{{/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *
  *  Create the name of the service account to use
  *
  */}}
{{- define "haproxy-ingress.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "haproxy-ingress.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}


{{/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
  *
  * Construct the path for publish-service
  * 
  */}}
{{- define "haproxy-ingress.controller.publishServicePath" -}}
  {{- if .Values.controller.publishService.pathOverride }}
    {{- .Values.controller.publishService.pathOverride | trimSuffix "-" }}
  {{- else }}
    {{- printf "%s/%s" "$(POD_NAMESPACE)" (include "haproxy-ingress.fullname" .) | trimSuffix "-" }}
  {{- end }}
{{- end }}

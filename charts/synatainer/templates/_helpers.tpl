{{/*
Expand the name of the chart.
*/}}
{{- define "synatainer.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "synatainer.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "synatainer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "synatainer.labels" -}}
helm.sh/chart: {{ include "synatainer.chart" . }}
{{ include "synatainer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "synatainer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "synatainer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "synatainer.mxtoken" -}}
{{- printf "*|*|*|%s" (required "You need to specify a synapse token" .Values.synapse.token) }}
{{- end }}

{{- define "synatainer.pgpassword" -}}
{{- printf "%s:%s:%s:%s:%s" (required "You need to specify a postgres host" .Values.postgresql.host) (.Values.postgresql.port | default 5432 | toString) (.Values.postgresql.database | default "synapse") (.Values.postgresql.username | default "synapse") (required "You need to specify a postgres password" .Values.postgresql.password) }}
{{- end }}

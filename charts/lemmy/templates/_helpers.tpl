{{/*
Expand the name of the chart.
*/}}
{{- define "lemmy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lemmy.fullname" -}}
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

{{- define "lemmy.uiname" -}}
{{- printf "%s-%s" (include "lemmy.fullname" $) "ui" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "lemmy.proxyname" -}}
{{- printf "%s-%s" (include "lemmy.fullname" $) "proxy" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "lemmy.pictrsname" -}}
{{- printf "%s-%s" (include "lemmy.fullname" $) "pictrs" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "lemmy.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lemmy.labels" -}}
helm.sh/chart: {{ include "lemmy.chart" . }}
{{ include "lemmy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lemmy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lemmy.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lemmy.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lemmy.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "lemmy.postgresql.fullname" -}}
{{- $name := .Values.postgresql.nameOverride | default "postgresql" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "lemmy.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "lemmy.postgresql.fullname" . -}}
{{- else -}}
{{ required "A valid postgresql.host is required" .Values.postgresql.host }}
{{- end -}}
{{- end -}}

{{/*
Set postgres secret
*/}}
{{- define "lemmy.postgresql.secret" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "lemmy.postgresql.fullname" . -}}
{{- else -}}
{{- template "lemmy.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres port
*/}}
{{- define "lemmy.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{-   if .Values.postgresql.service -}}
{{-     .Values.postgresql.service.port | default 5432 }}
{{-   else -}}
5432
{{-   end -}}
{{- else -}}
5432
{{- end -}}
{{- end -}}

{{/*
Set postgresql username
*/}}
{{- define "lemmy.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.username | default "postgres" }}
{{- else -}}
{{ required "A valid postgresql.auth.username is required" .Values.postgresql.auth.username }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql password
*/}}
{{- define "lemmy.postgresql.password" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.password | default "" }}
{{- else -}}
{{ required "A valid postgresql.auth.password is required" .Values.postgresql.auth.password }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql database
*/}}
{{- define "lemmy.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database | default "lemmy" }}
{{- else -}}
{{ required "A valid postgresql.auth.database is required" .Values.postgresql.auth.database }}
{{- end -}}
{{- end -}}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "matrix-media-repo.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "matrix-media-repo.fullname" -}}
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
{{- define "matrix-media-repo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Get the correct image tag name
*/}}
{{- define "matrix-media-repo.imageTag" -}}
{{- .Values.image.tag | default (printf "v%s" .Chart.AppVersion) -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "matrix-media-repo.labels" -}}
helm.sh/chart: {{ include "matrix-media-repo.chart" . }}
{{ include "matrix-media-repo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "matrix-media-repo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "matrix-media-repo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "matrix-media-repo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "matrix-media-repo.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-media-repo.postgresql.fullname" -}}
{{- $name := .Values.postgresql.nameOverride | default "postgresql" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "matrix-media-repo.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "matrix-media-repo.postgresql.fullname" . -}}
{{- else -}}
{{ required "A valid externalPostgresql.host is required" .Values.externalPostgresql.host }}
{{- end -}}
{{- end -}}

{{/*
Set postgres secret
*/}}
{{- define "matrix-media-repo.postgresql.secret" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "matrix-media-repo.postgresql.fullname" . -}}
{{- else -}}
{{- template "matrix-media-repo.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres port
*/}}
{{- define "matrix-media-repo.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{-   if .Values.postgresql.service -}}
{{- .Values.postgresql.service.port | default 5432 }}
{{-   else -}}
5432
{{-   end -}}
{{- else -}}
{{- required "A valid externalPostgresql.port is required" .Values.externalPostgresql.port -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql username
*/}}
{{- define "matrix-media-repo.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.username | default "postgres" }}
{{- else -}}
{{ required "A valid externalPostgresql.username is required" .Values.externalPostgresql.username }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql password
*/}}
{{- define "matrix-media-repo.postgresql.password" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.password | default "" }}
{{- else -}}
{{ required "A valid externalPostgresql.password is required" .Values.externalPostgresql.password }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql database
*/}}
{{- define "matrix-media-repo.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- .Values.postgresql.auth.database | default "synapse" }}
{{- else -}}
{{ required "A valid externalPostgresql.database is required" .Values.externalPostgresql.database }}
{{- end -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-media-repo.redis.fullname" -}}
{{- $name := .Values.redis.nameOverride | default "redis" -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set redis host
*/}}
{{- define "matrix-media-repo.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- printf "%s-%s" (include "matrix-media-repo.redis.fullname" .) "master" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{ required "A valid externalRedis.host is required" .Values.externalRedis.host }}
{{- end -}}
{{- end -}}

{{/*
Set redis secret
*/}}
{{- define "matrix-media-repo.redis.secret" -}}
{{- if .Values.redis.enabled -}}
{{- if .Values.redis.auth.existingSecret -}}
{{ .Values.redis.auth.existingSecret }}
{{- else -}}
{{- template "matrix-media-repo.redis.fullname" . -}}
{{- end -}}
{{- else -}}
{{- template "matrix-media-repo.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set redis port
*/}}
{{- define "matrix-media-repo.redis.port" -}}
{{- if .Values.redis.enabled -}}
{{- .Values.redis.master.service.port | default 6379 }}
{{- else -}}
{{ required "A valid externalRedis.port is required" .Values.externalRedis.port }}
{{- end -}}
{{- end -}}

{{/*
Set redis password
*/}}
{{- define "matrix-media-repo.redis.password" -}}
{{- if .Values.redis.enabled -}}
{{ .Values.redis.password }}
{{- else if .Values.externalRedis.password -}}
{{ .Values.externalRedis.password }}
{{- end -}}
{{- end -}}

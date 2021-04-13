{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "matrix-synapse.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "matrix-synapse.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create a default replication name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.replicationname" -}}
{{- printf "%s-%s" .Release.Name "replication" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default worker name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.workername" -}}
{{- printf "%s-%s" .global.Release.Name .worker | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default external component name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.externalname" -}}
{{- printf "%s-%s" .global.Release.Name .external | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "matrix-synapse.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Get the correct image tag name
*/}}
{{- define "matrix-synapse.imageTag" -}}
{{- .Values.image.tag | default (printf "v%s" .Chart.AppVersion) -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "matrix-synapse.labels" -}}
helm.sh/chart: {{ include "matrix-synapse.chart" . }}
{{ include "matrix-synapse.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "matrix-synapse.selectorLabels" -}}
app.kubernetes.io/name: {{ include "matrix-synapse.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Pull secrets
*/}}
{{- define "matrix-synapse.imagePullSecrets" -}}
{{- if or .Values.image.pullSecrets .Values.wellknown.image.pullSecrets .Values.volumePermissions.pullSecrets }}
imagePullSecrets:
{{- with .Values.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with .Values.wellknown.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with .Values.volumePermissions.image.pullSecrets }}
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.postgresql.fullname" -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "matrix-synapse.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Set postgres host
*/}}
{{- define "matrix-synapse.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "matrix-synapse.postgresql.fullname" . -}}
{{- else -}}
{{ required "A valid externalPostgresql.host is required" .Values.externalPostgresql.host }}
{{- end -}}
{{- end -}}

{{/*
Set postgres secret
*/}}
{{- define "matrix-synapse.postgresql.secret" -}}
{{- if .Values.postgresql.enabled -}}
{{- template "matrix-synapse.postgresql.fullname" . -}}
{{- else -}}
{{- template "matrix-synapse.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set postgres port
*/}}
{{- define "matrix-synapse.postgresql.port" -}}
{{- if .Values.postgresql.enabled -}}
{{- if .Values.postgresql.service -}}
{{- default 5432 .Values.postgresql.service.port }}
{{- else -}}
5432
{{- end -}}
{{- else -}}
{{- required "A valid externalPostgresql.port is required" .Values.externalPostgresql.port -}}
{{- end -}}
{{- end -}}

{{/*
Set postgresql username
*/}}
{{- define "matrix-synapse.postgresql.username" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "postgres" .Values.postgresql.postgresqlUsername }}
{{- else -}}
{{ required "A valid externalPostgresql.username is required" .Values.externalPostgresql.username }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql password
*/}}
{{- define "matrix-synapse.postgresql.password" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "" .Values.postgresql.postgresqlPassword }}
{{- else -}}
{{ required "A valid externalPostgresql.password is required" .Values.externalPostgresql.password }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql database
*/}}
{{- define "matrix-synapse.postgresql.database" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "synapse" .Values.postgresql.postgresqlDatabase }}
{{- else -}}
{{ required "A valid externalPostgresql.database is required" .Values.externalPostgresql.database }}
{{- end -}}
{{- end -}}

{{/*
Set postgresql sslmode
*/}}
{{- define "matrix-synapse.postgresql.sslmode" -}}
{{- if .Values.postgresql.enabled -}}
{{- default "prefer" .Values.postgresql.sslmode }}
{{- else -}}
{{- default "prefer" .Values.externalPostgresql.sslmode }}
{{- end -}}
{{- end -}}

{{/*
Set redis host
*/}}
{{- define "matrix-synapse.redis.host" -}}
{{- if .Values.redis.enabled -}}
{{- template "matrix-synapse.redis.fullname" . -}}-master
{{- else -}}
{{ required "A valid externalRedis.host is required" .Values.externalRedis.host }}
{{- end -}}
{{- end -}}

{{/*
Set redis secret
*/}}
{{- define "matrix-synapse.redis.secret" -}}
{{- if .Values.redis.enabled -}}
{{- template "matrix-synapse.redis.fullname" . -}}
{{- else -}}
{{- template "matrix-synapse.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Set redis port
*/}}
{{- define "matrix-synapse.redis.port" -}}
{{- if .Values.redis.enabled -}}
{{- default 6379 .Values.redis.redisPort }}
{{- else -}}
{{ required "A valid externalRedis.port is required" .Values.externalRedis.port }}
{{- end -}}
{{- end -}}

{{/*
Set redis password
*/}}
{{- define "matrix-synapse.redis.password" -}}
{{- if .Values.redis.enabled -}}
{{ .Values.redis.password }}
{{- else -}}
{{ .Values.externalRedis.password }}
{{- end -}}
{{- end -}}

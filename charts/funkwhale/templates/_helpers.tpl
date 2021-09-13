{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "funkwhale.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "funkwhale.dbUrl" -}}
{{- if and .Values.postgresql.enabled .Values.postgresql.host -}}
{{ fail "Setting both postgresql.enabled and postgresql.host will deploy an internal Postgres service and attempt to use an external one - please set only one of the two!" }}
{{- else if .Values.postgresql.enabled -}}
postgres://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ template "funkwhale.fullname" . }}-postgresql:{{ .Values.postgresql.service.port }}/{{ .Values.postgresql.postgresqlDatabase }}
{{- else if .Values.postgresql.host -}}
postgres://{{ .Values.postgresql.postgresqlUsername }}:{{ .Values.postgresql.postgresqlPassword }}@{{ .Values.postgresql.host }}:{{ .Values.postgresql.service.port }}/{{ .Values.postgresql.postgresqlDatabase }}
{{- else -}}
{{ fail "Either postgresql.enabled or postgresql.host are required!" }}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "funkwhale.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "funkwhale.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the correct image tag name
*/}}
{{- define "funkwhale.imageTag" -}}
{{- .Values.image.tag | default .Chart.AppVersion -}}
{{- end -}}

{{- define "funkwhale.redisUrl" -}}
{{- if and .Values.redis.enabled .Values.redis.host -}}
{{ fail "Setting both redis.enabled and redis.host will deploy an internal Redis service and attempt to use an external one - please set only one of the two!" }}
{{- else if .Values.redis.enabled -}}
redis://:{{ .Values.redis.password }}@{{ template "funkwhale.fullname" . }}-redis-master:{{ .Values.redis.redisPort }}/0
{{- else if .Values.redis.host -}}
redis://:{{ .Values.redis.password }}@{{ .Values.redis.host }}:{{ .Values.redis.redisPort }}/0
{{- else -}}
{{ fail "Either redis.enabled or redis.host are required!" }}
{{- end -}}
{{- end -}}

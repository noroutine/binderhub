{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Render docker config.json for the registry-publishing secret and other docker configuration.
*/}}
{{- define "buildDockerConfig" -}}

{{- /* default auth url */ -}}
{{- $url := (default "https://index.docker.io/v1" .Values.registry.url) }}

{{- /* default username if unspecified
  (_json_key for gcr.io, <token> otherwise)
*/ -}}

{{- if not .Values.registry.username }}
  {{- if eq $url "https://gcr.io" }}
    {{- $_ := set .Values.registry "username" "_json_key" }}
  {{- else }}
    {{- $_ := set .Values.registry "username" "<token>" }}
  {{- end }}
{{- end }}
{{- $username := .Values.registry.username -}}

{{- /* initialize a dict to represent a docker config with registry credentials */}}
{{- $dockerConfig := dict "auths" (dict $url (dict "auth" (printf "%s:%s" $username .Values.registry.password | b64enc))) }}

{{- /* augment our initialized docker config with buildDockerConfig */}}
{{- if .Values.config.BinderHub.buildDockerConfig }}
{{- $dockerConfig := merge $dockerConfig .Values.config.BinderHub.buildDockerConfig }}
{{- end }}

{{- $dockerConfig | toPrettyJson }}
{{- end }}

{{- /*
  binderhub.appLabel:
    Used by "binderhub.labels".
*/}}
{{- define "binderhub.appLabel" -}}
{{ .Values.nameOverride | default .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- /*
  binderhub.commonLabels:
    Foundation for "binderhub.labels".
    Provides labels: app, release, (chart and heritage).
*/}}
{{- define "binderhub.commonLabels" -}}
app: {{ .appLabel | default (include "binderhub.appLabel" .) }}
release: {{ .Release.Name }}
{{- if not .matchLabels }}
chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
heritage: {{ .heritageLabel | default .Release.Service }}
{{- end }}
{{- end }}

{{- /*
  binderhub.componentLabel:
    Used by "binderhub.labels".

    NOTE: The component label is determined by either...
    - 1: The provided scope's .componentLabel
    - 2: The template's filename if living in the root folder
    - 3: The template parent folder's name
    -  : ...and is combined with .componentPrefix and .componentSuffix
*/}}
{{- define "binderhub.componentLabel" -}}
binder
{{- end }}

{{- /*
  binderhub.labels:
    Provides labels: component, app, release, (chart and heritage).
*/}}
{{- define "binderhub.labels" -}}
component: {{ include "binderhub.componentLabel" . }}
{{ include "binderhub.commonLabels" . }}
{{- end }}


{{- /*
  binderhub.matchLabels:
    Used to provide pod selection labels: component, app, release.
*/}}
{{- define "binderhub.matchLabels" -}}
{{- $_ := merge (dict "matchLabels" true) . -}}
{{ include "binderhub.labels" $_ }}
{{- end }}
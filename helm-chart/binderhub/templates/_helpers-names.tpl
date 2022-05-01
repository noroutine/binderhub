{{- /*
    Utility templates
*/}}

{{- /*
    Renders to a prefix for the chart's resource names. This prefix is assumed to
    make the resource name cluster unique.
*/}}

{{- define "binderhub.fullname" -}}
    {{- $fullname_override := .Values.fullnameOverride }}
    {{- $name_override := .Values.nameOverride }}

    {{- if eq (typeOf $fullname_override) "string" }}
        {{- $fullname_override }}
    {{- else }}
        {{- $name := $name_override | default .Chart.Name }}
        {{- if contains $name .Release.Name }}
            {{- .Release.Name }}
        {{- else }}
            {{- .Release.Name }}-{{ $name }}
        {{- end }}
    {{- end }}
{{- end }}

{{- /*
    Renders to a blank string or if the fullname template is truthy renders to it
    with an appended dash.
*/}}
{{- define "binderhub.fullname.dash" -}}
    {{- if (include "binderhub.fullname" .) }}
        {{- include "binderhub.fullname" . }}-
    {{- end }}
{{- end }}
{{/*
Expand the chart name.
*/}}
{{- define "sre-project.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "sre-project.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sre-project.labels" -}}
app.kubernetes.io/name: {{ include "sre-project.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
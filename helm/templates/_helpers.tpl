{{- define "service.fullname" -}}
{{- if .Values.env -}}
{{ .Values.service.name }}-{{ .Values.env }}
{{- else -}}
{{ .Values.service.name }}
{{- end -}}
{{- end }}

{{- define "service.namespace" -}}
{{ .Values.env }}
{{- end }}

{{- define "service.hostname" -}}
{{- if .Values.env -}}
{{ .Values.service.name }}-{{ .Values.env }}.{{ .Values.global.domain }}
{{- else -}}
{{ .Values.service.name }}.{{ .Values.global.domain }}
{{- end -}}
{{- end }}

{{- define "service.fullname" -}}
{{ .Values.service.name }}-{{ .Values.env }}
{{- end }}

{{- define "service.namespace" -}}
{{ .Values.env }}
{{- end }}

{{- define "service.hostname" -}}
{{ .Values.service.name }}-{{ .Values.env }}.{{ .Values.global.domain }}
{{- end }}

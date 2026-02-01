{{ define "__subject" }}
[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ len .Alerts.Firing }}{{ end }}]
{{ end }}

{{ define "__alert_list" }}
{{ range . }}
---
{{ if .Labels.owner }}@{{ .Labels.owner }}{{ end }}

**告警主题**: {{ .Annotations.summary }}

**告警类型**: {{ .Labels.alertname }}

// 告警级别显示，使用颜色标记
**告警级别**: {{ if eq .Labels.severity "严重告警" }}:red:{{ else if eq .Labels.severity "warning" }}:yellow:{{ else }}:green:{{ end }} {{ .Labels.severity }}

**告警主机**: {{ .Labels.instance }}

**告警信息**: {{ index .Annotations "description" }}

// 以下为新增的告警详细信息
**告警来源**: {{ .Labels.alertsource }}

**监控指标**: {{ .Labels.metric }}

**触发条件**: {{ .Annotations.trigger_condition }}

**告警时间**: {{ dateInZone "2006.01.02 15:04:05" (.StartsAt) "Asia/Shanghai" }}
{{ end }}
{{ end }}

{{ define "__resolved_list" }}
{{ range . }}
---
{{ if .Labels.owner }}@{{ .Labels.owner }}{{ end }}

**告警主题**: {{ .Annotations.summary }}

**告警类型**: {{ .Labels.alertname }}

// 告警级别显示，使用颜色标记
**告警级别**: {{ if eq .Labels.severity "严重告警" }}:red:{{ else if eq .Labels.severity "warning" }}:yellow:{{ else }}:green:{{ end }} {{ .Labels.severity }}

**告警主机**: {{ .Labels.instance }}

**告警信息**: {{ index .Annotations "description" }}

**告警时间**: {{ dateInZone "2006.01.02 15:04:05" (.StartsAt) "Asia/Shanghai" }}

**恢复时间**: {{ dateInZone "2006.01.02 15:04:05" (.EndsAt) "Asia/Shanghai" }}
{{ end }}
{{ end }}

{{ define "default.title" }}
{{ template "__subject" . }}
{{ end }}

{{ define "default.content" }}
{{ if gt (len .Alerts.Firing) 0 }}
**====侦测到{{ len .Alerts.Firing }}个故障====**
{{ template "__alert_list" .Alerts.Firing }}
---
{{ end }}

{{ if gt (len .Alerts.Resolved) 0 }}
**====恢复{{ len .Alerts.Resolved }}个故障====**
{{ template "__resolved_list" .Alerts.Resolved }}
{{ end }}
{{ end }}

{{ define "ding.link.title" }}
{{ template "default.title" . }}
{{ end }}

{{ define "ding.link.content" }}
{{ template "default.content" . }}
{{ end }}

{{ template "default.title" . }}
{{ template "default.content" . }}

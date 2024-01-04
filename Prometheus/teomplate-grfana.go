package main

import (
	"fmt"
	"html/template"
	"time"
)

// 模拟警报数据结构
type AlertData struct {
	Status string
	Alerts struct {
		Firing   []Alert
		Resolved []Alert
	}
}

// 模拟告警结构
type Alert struct {
	Labels      Labels
	Annotations Annotations
	StartsAt    time.Time
	EndsAt      time.Time
}

// 模拟标签结构
type Labels struct {
	Owner       string
	Alertname   string
	Severity    string
	Instance    string
	Alertsource string
	Metric      string
}

// 模拟注释结构
type Annotations struct {
	Summary          string
	Description      string
	TriggerCondition string
}

// 模拟数据
var alertData = AlertData{
	Status: "firing",
	Alerts: struct {
		Firing   []Alert
		Resolved []Alert
	}{
		Firing: []Alert{
			{
				Labels: Labels{
					Owner:       "user1",
					Alertname:   "HighCPU",
					Severity:    "严重告警",
					Instance:    "server1",
					Alertsource: "Prometheus",
					Metric:      "CPU Usage",
				},
				Annotations: Annotations{
					Summary:          "High CPU Usage Detected",
					Description:      "CPU usage is above 90% on server1",
					TriggerCondition: "CPU usage > 90%",
				},
				StartsAt: time.Now().Add(-1 * time.Hour),
			},
		},
		Resolved: []Alert{},
	},
}

// 渲染模板
func renderTemplate(templateName string, data interface{}) string {
	tmpl, err := template.New("template").Parse(templateString)
	if err != nil {
		fmt.Println("Error parsing template:", err)
		return ""
	}

	var renderedContent string
	err = tmpl.ExecuteTemplate(&renderedContent, templateName, data)
	if err != nil {
		fmt.Println("Error rendering template:", err)
		return ""
	}

	return renderedContent
}

// 模板字符串
var templateString = `
{{ define "__grafana_link" }}
[Grafana 仪表盘](https://your-grafana-dashboard-link)
{{ end }}

{{ define "__subject" }}
[{{ .Status | toUpper }}{{ if eq .Status "firing" }}:{{ len .Alerts.Firing }}{{ end }}]
{{ end }}

{{ define "__alert_list" }}
{{ range . }}
---
{{ if .Labels.Owner }}@{{ .Labels.Owner }}{{ end }}

**告警主题**: {{ .Annotations.Summary }}

**告警类型**: {{ .Labels.Alertname }}

# 告警级别显示，使用颜色标记
**告警级别**: {{ if eq .Labels.Severity "严重告警" }}:red:{{ else if eq .Labels.Severity "warning" }}:yellow:{{ else }}:green:{{ end }} {{ .Labels.Severity }}

**告警主机**: {{ .Labels.Instance }}

**告警信息**: {{ .Annotations.Description }}

# 以下为新增的告警详细信息
**告警来源**: {{ .Labels.Alertsource }}

**监控指标**: {{ .Labels.Metric }}

**触发条件**: {{ .Annotations.TriggerCondition }}

**告警时间**: {{ .StartsAt.Format "2006.01.02 15:04:05" }}
{{ end }}
{{ end }}

{{ define "__resolved_list" }}
{{ range . }}
---
{{ if .Labels.Owner }}@{{ .Labels.Owner }}{{ end }}

**告警主题**: {{ .Annotations.Summary }}

**告警类型**: {{ .Labels.Alertname }}

# 告警级别显示，使用颜色标记
**告警级别**: {{ if eq .Labels.Severity "严重告警" }}:red:{{ else if eq .Labels.Severity "warning" }}:yellow:{{ else }}:green:{{ end }} {{ .Labels.Severity }}

**告警主机**: {{ .Labels.Instance }}

**告警信息**: {{ .Annotations.Description }}

**告警时间**: {{ .StartsAt.Format "2006.01.02 15:04:05" }}

**恢复时间**: {{ .EndsAt.Format "2006.01.02 15:04:05" }}
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

{{ template "__grafana_link" . }}
{{ end }}

{{ define "ding.link.title" }}
{{ template "default.title" . }}
{{ end }}

{{ define "ding.link.content" }}
{{ template "default.content" . }}
{{ end }}

{{ template "ding.link.title" . }}
{{ template "ding.link.content" . }}
`

func main() {
	// 渲染模板并输出结果
	renderedContent := renderTemplate("ding.link.content", alertData)	
	fmt.Println(renderedContent)
}

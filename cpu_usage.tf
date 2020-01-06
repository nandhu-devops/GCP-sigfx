resource "signalfx_detector" "cpuUsage" {
  name         = "kafka-gcp-cpuUsage-staging"
  description  = "Graph for kafka-cpuUsage-gcp"
  max_delay    = 30
  program_text = <<-EOF
      signal = data('instance/cpu/utilization',filter('project_id','mist-platform-staging') and filter('instance_name','kafka-*')).scale(100)
      detect( when(signal > 90, '5m')).publish('kafka cpu-Usage is above 90 percent')
     
EOF


  rule {
    description   = "kafka cpu-Usage is above 90 percent"
    severity      = "Critical"
    detect_label  = "kafka cpu-Usage is above 90 percent"
    notifications = ["Slack,C0fLUxBAgAA,devops-gcp"]

    parameterized_body = <<-EOF

         {{#if anomalous}}
         Rule {{ruleName}} in detector {{detectorName}} triggered at {{timestamp}}
         {{else}}
         Rule "{{ruleName}}" in detector "{{detectorName}}" cleared at {{timestamp}}
         {{/if}}

         {{#if anomalous}}
         Triggering condition: Free Memory is below 10 
         {{/if}}

         {{#if anomalous}}Signal value: {{inputs.signal.value}}
         {{else}}Current signal value: {{inputs.signal.value}}
         {{/if}}

         {{#notEmpty dimensions}}
         Signal details:
         {{{dimensions}}}
         {{/notEmpty}}

EOF

  }
}


resource "signalfx_detector" "ebs_data" {
  name         = "kafka-gcp-ebs/data-staging"
  description  = "Graph for kafka-ebs/data-gcp"
  max_delay    = 30
  program_text = <<-EOF
      signal = data('_data.byte_percentfree',filter('prefix', 'kafka_brokers') and filter('env', 'gcp-staging') and filter('collector','diskspace') and filter('host','kafka-*')).mean(over='5m')
      detect( when(signal < 10, '10m')).publish('kafka ebs/data is below 10 percent')
     
EOF


  rule {
    description   = "kafka ebs/data is below 10 percent"
    severity      = "Critical"
    detect_label  = "kafka ebs/data is below 10 percent"
    notifications = ["Slack,C0fLUxBAgAA,devops-gcp"]

    parameterized_body = <<-EOF

         {{#if anomalous}}
         Rule {{ruleName}} in detector {{detectorName}} triggered at {{timestamp}}
         {{else}}
         Rule "{{ruleName}}" in detector "{{detectorName}}" cleared at {{timestamp}}
         {{/if}}

         {{#if anomalous}}
         Triggering condition: ebs/data is below 10 
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


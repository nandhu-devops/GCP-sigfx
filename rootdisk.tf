resource "signalfx_detector" "rootdisk" {
  name         = "kafka-gcp-rootdisk-staging"
  description  = "Graph for kafka-rootdisk-gcp"
  max_delay    = 30
  program_text = <<-EOF
      signal = data('cloudimg-rootfs.byte_percentfree',filter('prefix', 'kafka_brokers') and filter('env', 'gcp-staging') and filter('collector','diskspace') and filter('host','kafka-*')).mean(over='5m')
      detect( when(signal < 10, '10m')).publish('kafka rootdisk is below 10 percent')
     
EOF


  rule {
    description   = "kafka rootdisk disk is below 10 percent"
    severity      = "Critical"
    detect_label  = "kafka rootdisk is below 10 percent"
    notifications = ["Slack,C0fLUxBAgAA,devops-gcp"]

    parameterized_body = <<-EOF

         {{#if anomalous}}
         Rule {{ruleName}} in detector {{detectorName}} triggered at {{timestamp}}
         {{else}}
         Rule "{{ruleName}}" in detector "{{detectorName}}" cleared at {{timestamp}}
         {{/if}}

         {{#if anomalous}}
         Triggering condition: Rootdisk is below 10 
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


#!/usr/bin/env ruby

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")
require "slack-notify"
require "yaml"

def send_notification(msg)
  webhook_url = "https://hooks.slack.com/services/#{ENV.fetch("SLACK_WEBHOOK")}"

  SlackNotify::Client.new(
    channel: "#cloud-platform",
    webhook_url: webhook_url,
    username: "Namespace deleter",
    icon_emoji: ":killitwithfire:"
  ).notify(msg)
end

namespaces = deleted_namespaces("live.cloud-platform.service.justice.gov.uk")

production_namespaces = namespaces.select do |namespace|
  yaml_file_path = File.join("..", "namespaces", "live.cloud-platform.service.justice.gov.uk", namespace, "00-namespace.yaml")
  if File.exist?(yaml_file_path)
    yaml_content = YAML.load_file(yaml_file_path)
    yaml_content.dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production") == "true"
  else
    false
  end
end

if production_namespaces.any?
  msg = <<~EOF
    The following production namespaces have been removed from the environments repository:

      - #{production_namespaces.join("\n  - ")}

    Please delete them:

    https://runbooks.cloud-platform.service.justice.gov.uk/manually-delete-namespace-resources.html#manually-delete-namespace-resources

  EOF

  puts msg
  send_notification(msg)
else
  puts "No production namespaces to delete"
end
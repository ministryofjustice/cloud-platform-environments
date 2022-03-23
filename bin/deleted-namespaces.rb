#!/usr/bin/env ruby

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

require "slack-notify"

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

if namespaces.any?
  msg = <<~EOF
    The following namespaces have been removed from the environments repository:

      - #{namespaces.join("\n  - ")}

    Please delete them:

    https://runbooks.cloud-platform.service.justice.gov.uk/manually-delete-namespace-resources.html#manually-delete-namespace-resources

  EOF

  puts msg
  send_notification(msg)
else
  puts "No namespaces to delete"
end

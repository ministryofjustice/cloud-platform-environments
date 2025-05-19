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

all_deleted_namespaces = deleted_namespaces("live.cloud-platform.service.justice.gov.uk")
production_namespaces = []
non_production_namespaces = []

puts "🔍 Checking deleted namespaces..."

all_deleted_namespaces.each do |ns|
  deleter = NamespaceDeleter.new(namespace: ns)

  if deleter.send(:safe_to_delete?)
    non_production_namespaces << ns
  else
    # Check if it's production
    k8s_ns = deleter.k8s_client.get_namespace(ns) rescue nil
    if k8s_ns && k8s_ns.metadata.labels[NamespaceDeleter::PRODUCTION_LABEL] == NamespaceDeleter::LABEL_TRUE
      production_namespaces << ns
    end
  end
end

if production_namespaces.any?
  msg = <<~EOF
    ⚠️ The following production namespaces have been removed from the environments repo **but must be deleted manually**:

      - #{production_namespaces.join("\n  - ")}

    Follow manual deletion steps:
    https://runbooks.cloud-platform.service.justice.gov.uk/manually-delete-namespace-resources.html#manually-delete-namespace-resources
  EOF

  puts msg
  send_notification(msg)
end

if non_production_namespaces.any?
  msg = <<~EOF
    ✅ The following namespaces were removed and can be safely deleted:

      - #{non_production_namespaces.join("\n  - ")}

    Proceed with automated deletion or review as needed.
  EOF

  puts msg
  send_notification(msg)
end

if production_namespaces.empty? && non_production_namespaces.empty?
  puts "No namespaces to delete."
end

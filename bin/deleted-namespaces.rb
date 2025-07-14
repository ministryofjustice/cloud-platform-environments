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

env = "live.cloud-platform.service.justice.gov.uk"

begin
  def is_merge_commit?
    parents = `git rev-list --parents -n 1 HEAD`.strip.split
    parents.length > 2
  end

  commit_range = if is_merge_commit?
    first_parent = `git rev-parse HEAD^1`.strip
    "#{first_parent}..HEAD"
  else
    previous_commit = `git rev-parse HEAD~1`.strip
    "#{previous_commit}..HEAD"
  end
rescue => e
  commit_range = "HEAD"
end

raw_diff = `git diff --name-status #{commit_range}`

deleted_or_renamed_lines = raw_diff.lines.select do |line|
  line.start_with?("D", "R")
end

deleted_namespace_paths = deleted_or_renamed_lines.map do |line|
  parts = line.strip.split("\t")
  old_path = parts[1]

  if old_path =~ %r{\Anamespaces/#{Regexp.escape(env)}/([^/]+)/00-namespace.yaml\z}
    namespace = Regexp.last_match(1)
    [namespace, old_path]
  end
end.compact

production_namespaces = deleted_namespace_paths.select do |namespace, path|
  last_commit = `git rev-list -n 1 HEAD -- #{path}`.strip

  next false if last_commit.empty?

  content = `git show #{last_commit}:#{path} 2>/dev/null`
  if content.empty?
    parent_commit = `git rev-parse #{last_commit}^`.strip
    content = `git show #{parent_commit}:#{path} 2>/dev/null`
    if content.empty?
      next false
    else
      begin
        yaml_content = YAML.safe_load(content)
        yaml_content.dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production") == "true"
      rescue Psych::SyntaxError => e
        false
      end
    end
  else
    begin
      yaml_content = YAML.safe_load(content)
      yaml_content.dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production") == "true"
    rescue Psych::SyntaxError => e
      false
    end
  end
end.map(&:first)

if production_namespaces.any?
  msg = <<~EOF
    The following production namespaces have been removed or renamed from the environments repository:
      - #{production_namespaces.join("\n  - ")}
    Please delete them manually:
    https://runbooks.cloud-platform.service.justice.gov.uk/manually-delete-namespace-resources.html#manually-delete-namespace-resources
  EOF
  send_notification(msg)
else
  puts "No production namespaces have been deleted."
end

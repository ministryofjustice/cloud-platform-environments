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
commit_range = "origin/main..HEAD"

puts "DEBUG: Using commit range: #{commit_range}"
puts "DEBUG: Environment: #{env}"

raw_diff = `git diff --name-status #{commit_range}`
puts "DEBUG: Raw git diff output:\n#{raw_diff}"

deleted_or_renamed_lines = raw_diff.lines.select do |line|
  puts "DEBUG: Processing line: #{line.strip}"
  line.start_with?("D", "R")
end

puts "DEBUG: Deleted or renamed lines:\n#{deleted_or_renamed_lines.join}"

deleted_namespace_paths = deleted_or_renamed_lines.map do |line|
  parts = line.strip.split("\t")
  old_path = parts[1]
  puts "DEBUG: Processing old path: #{old_path}"

  if old_path =~ %r{\Anamespaces/#{Regexp.escape(env)}/([^/]+)/00-namespace.yaml\z}
    namespace = Regexp.last_match(1)
    puts "DEBUG: Matched namespace: #{namespace}"
    [namespace, old_path]
  else
    puts "DEBUG: Path does not match namespace pattern: #{old_path}"
    nil
  end
end.compact

puts "DEBUG: Deleted namespace paths:\n#{deleted_namespace_paths.inspect}"

production_namespaces = deleted_namespace_paths.select do |namespace, path|
  last_commit = `git rev-list -n 1 HEAD -- #{path}`.strip
  puts "DEBUG: Last commit for #{path}: #{last_commit}"

  next false if last_commit.empty?

  content = `git show #{last_commit}:#{path} 2>/dev/null`
  if content.empty?
    parent_commit = `git rev-parse #{last_commit}^`.strip
    content = `git show #{parent_commit}:#{path} 2>/dev/null`
    if content.empty?
      puts "DEBUG: File #{path} empty in commit #{last_commit} and its parent #{parent_commit}, skipping"
      next false
    else
      begin
        yaml_content = YAML.safe_load(content)
        puts "DEBUG: Parsed YAML content for #{path} in parent commit #{parent_commit}:\n#{yaml_content.inspect}"
        yaml_content.dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production") == "true"
      rescue Psych::SyntaxError => e
        puts "DEBUG: YAML parse error for #{path} in commit #{parent_commit}: #{e.message}"
        false
      end
    end
  else
    begin
      yaml_content = YAML.safe_load(content)
      puts "DEBUG: Parsed YAML content for #{path} in commit #{last_commit}:\n#{yaml_content.inspect}"
      yaml_content.dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production") == "true"
    rescue Psych::SyntaxError => e
      puts "DEBUG: YAML parse error for #{path} in commit #{last_commit}: #{e.message}"
      false
    end
  end
end.map(&:first)

puts "DEBUG: Production namespaces detected:\n#{production_namespaces.inspect}"

if production_namespaces.any?
  puts "DEBUG: Entering production namespaces block. Detected namespaces: #{production_namespaces.inspect}"
  msg = <<~EOF
    The following production namespaces have been removed or renamed from the environments repository:
      - #{production_namespaces.join("\n  - ")}
    Please delete them manually:
    https://runbooks.cloud-platform.service.justice.gov.uk/manually-delete-namespace-resources.html#manually-delete-namespace-resources
  EOF
  puts msg
  send_notification(msg)
else
  puts "DEBUG: No production namespaces detected. Skipping notification."
end

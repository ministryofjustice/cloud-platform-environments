#!/usr/bin/env ruby

# This script outputs a report to assist in comparing the resources a namespace
# is requesting (and allowed to request), against what it actually uses.

# Usage tips:
#
# Get results for all namespaces:
#     ./bin/namespace-reporter.rb -n '.*' | tee namespace-report.txt
#
# Get results for all namespaces matching a string:
#     ./bin/namespace-reporter.rb -n prison-visits
#
# Store data in a json file
#     ./bin/namespace-reporter.rb -n '.*' -o json > namespaces.json
#
# Namespaces by number of containers
#     cat namespaces.json | jq -r '.items[] | [.container_count, .name] | join(", ")' | sort -n
#
# Total count of containers:
#     cat namespaces.json | jq '.items[].container_count' | paste -sd+ - | bc
# https://stackoverflow.com/a/18141152/794111

require 'json'
require 'optparse'

# Output formats
TEXT_OUTPUT = "text"
JSON_OUTPUT = "json"

class Namespace
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def report
    ns_quota = quota
    ns_limits = limits

    {
      name: name,
      resources_used: resources_used,
      default_request: default_request(ns_limits),
      default_limit: default_limit(ns_limits),
      max_requests: ns_quota.fetch(:hard_request_limit),
      hard_limit: ns_quota.fetch(:hard_limit),
      hard_limit_used: ns_quota.fetch(:hard_limit_used),
      resources_requested: ns_quota.fetch(:requested),
      container_count: container_count(name)
    }
  end

  def self.names(pattern)
    `kubectl get ns -o jsonpath='{.items[*].metadata.name}'`.chomp
      .split(' ')
      .grep(/#{pattern}/)
  end

  private

  def resources_used
    usage = `kubectl --namespace=#{name} top pod`

    lines = usage.split("\n")
    lines.shift

    hash = lines.inject({ cpu: [], memory: [] }) do |h, l|
      fields = l.split(" ")
      h[:cpu] << fields[1]
      h[:memory] << fields[2]
      h
    end

    cpu = hash[:cpu].inject(0) {|sum, c| sum += cpu_value(c)}
    memory = hash[:memory].inject(0) {|sum, c| sum += memory_value(c)}

    { cpu: cpu, memory: memory }
  end

  def default_request(limits)
    from_limits(limits, "defaultRequest")
  end

  def default_limit(limits)
    from_limits(limits, "default")
  end

  def from_limits(limits, value_type)
    data = limits.dig("spec", "limits")[0]
      .dig(value_type)

    {
      cpu: cpu_value(data.fetch("cpu", nil)),
      memory: memory_value(data.fetch("memory", nil))
    }
  rescue
    {
      cpu: nil,
      memory: nil
    }
  end

  def limits
    kubectl_get("limits")[0]
  end

  def quota
    quota = kubectl_get("quota")[0]

    if quota.nil?
      {
        hard_request_limit: {cpu: nil, memory: nil},
        hard_limit: {cpu: nil, memory: nil},
        requested: {cpu: nil, memory: nil},
        hard_limit_used: {cpu: nil, memory: nil}
      }
    else
      data = quota.dig("status")

      hard_request_limit = {
        cpu: cpu_value(data.dig("hard", "requests.cpu")),
        memory: memory_value(data.dig("hard", "requests.memory"))
      }

      hard_limit = {
        cpu: cpu_value(data.dig("hard", "limits.cpu")),
        memory: memory_value(data.dig("hard", "limits.memory"))
      }

      hard_limit_used = {
        cpu: cpu_value(data.dig("used", "limits.cpu")),
        memory: memory_value(data.dig("used", "limits.memory"))
      }

      requested = {
        cpu: cpu_value(data.dig("used", "requests.cpu")),
        memory: memory_value(data.dig("used", "requests.memory"))
      }

      {
        hard_request_limit: hard_request_limit,
        hard_limit: hard_limit,
        hard_limit_used: hard_limit_used,
        requested: requested
      }
    end
  end

  def container_count(name)
    data = kubectl_get("pods")
    data.collect {|i| i.dig("spec", "containers")}.flatten.compact.count
  end

  def kubectl_get(obj)
    JSON.parse(`kubectl --namespace=#{name} get #{obj} -o json`)
      .fetch("items")
  end

  def cpu_value(str)
    return nil if str.nil?

    case str
    when /^(\d+)$/
      $1.to_i * 1000
    when /^(\d+)m$/
      $1.to_i
    else
      raise %[CPU value: "#{str}" was not in expected format]
    end
  end

  def memory_value(str)
    return nil if str.nil?

    case str
    when /^(\d+)$/
      $1.to_i / 1_000
    when /^(\d+)k$/, /^(\d+)Ki$/
      $1.to_i / 1024
    when /^(\d+)m$/ # e.g. 6.4Gi in yaml => 6871947673600m in the JSON kubectl output
      $1.to_i / 1_000_000_000
    when /^(\d+)Gi/
      $1.to_i * 1000
    when /^(\d+)Mi/
      $1.to_i
    else
      raise %[Memory value: "#{str}" was not in expected format]
    end
  end
end

def text_output(ns)
  puts
  puts "Namespace: #{ns[:name]}"
  puts
  puts "  Request limit:\tCPU: #{ns[:max_requests][:cpu]},\tMemory: #{ns[:max_requests][:memory]}"
  puts "  Requested:\t\tCPU: #{ns[:resources_requested][:cpu]},\tMemory: #{ns[:resources_requested][:memory]}"
  puts
  puts "  Num. containers:\t#{ns[:container_count]}"
  puts "  Req. per-container:\tCPU: #{ns[:default_request][:cpu]},\tMemory: #{ns[:default_request][:memory]}"
  puts
  puts "  Resources in-use:\tCPU: #{ns[:resources_used][:cpu]},\tMemory: #{ns[:resources_used][:memory]}"
  puts
  puts "CPU values are in millicores (m). Memory values are in mebibytes (Mi)."
  puts
end

def parse_options
  options = { format: TEXT_OUTPUT }

  OptionParser.new do |opts|
    opts.on("-n", "--namespace NAMESPACE", "Namespace name pattern (required)") do |ns|
      options[:namespace] = ns
    end

    opts.on("-o", "--output [FORMAT]", [JSON_OUTPUT, TEXT_OUTPUT], "Output format (#{JSON_OUTPUT} | #{TEXT_OUTPUT})") do |fmt|
      options[:format] = fmt
    end

    opts.on_tail("-h", "--help", "Show help message") do
      puts opts
      exit
    end
  end.parse!

  options
end

############################################################

options = parse_options
pattern = options.fetch(:namespace)

names = Namespace.names(pattern)

if options.fetch(:format) == JSON_OUTPUT
  namespaces = names.map { |name| Namespace.new(name).report }
  puts({ items: namespaces, last_updated: Time.now }.to_json)
else
  names.each { |name| text_output(Namespace.new(name).report) }
end

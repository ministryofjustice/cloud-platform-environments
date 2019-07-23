#!/usr/bin/env ruby

# This script outputs a report to assist in comparing the resources a namespace
# is requesting (and allowed to request), against what it actually uses.

require 'json'

class Namespace
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def report
    ns_quota = quota

    {
      name: name,
      resources_used: resources_used,
      default_request: default_request,
      max_resources: ns_quota.fetch(:hard_request_limit),
      resources_requested: ns_quota.fetch(:requested),
      container_count: container_count(name)
    }
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

  def default_request
    limits = kubectl_get("limits")[0]

    if limits.nil?
      {
        cpu: nil,
        memory: nil
      }
    else
      data = limits.dig("spec", "limits")[0]
        .dig("defaultRequest")

      {
        cpu: cpu_value(data.fetch("cpu")),
        memory: memory_value(data.fetch("memory"))
      }
    end
  end

  def quota
    quota = kubectl_get("quota")[0]

    if quota.nil?
      {
        hard_request_limit: {cpu: nil, memory: nil},
        requested: {cpu: nil, memory: nil}
      }
    else
      data = quota.dig("status")

      hard_request_limit = {
        cpu: cpu_value(data.dig("hard", "requests.cpu")),
        memory: memory_value(data.dig("hard", "requests.memory"))
      }

      requested = {
        cpu: cpu_value(data.dig("used", "requests.cpu")),
        memory: memory_value(data.dig("used", "requests.memory"))
      }

      {
        hard_request_limit: hard_request_limit,
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
    case str
    when /^(\d+)$/
      $1.to_i / 1_000
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

############################################################

name = ARGV.shift

if name.nil?
  puts "USAGE: $0 [namespace name]"
  exit
end

ns = Namespace.new(name).report

puts
puts "Namespace: #{ns[:name]}"
puts
puts "  Request limit:\tCPU: #{ns[:max_resources][:cpu]},\tMemory: #{ns[:max_resources][:memory]}"
puts "  Requested:\t\tCPU: #{ns[:resources_requested][:cpu]},\tMemory: #{ns[:resources_requested][:memory]}"
puts
puts "  Num. containers:\t#{ns[:container_count]}"
puts "  Req. per-container:\tCPU: #{ns[:default_request][:cpu]},\tMemory: #{ns[:default_request][:memory]}"
puts
puts "  Resources in-use:\tCPU: #{ns[:resources_used][:cpu]},\tMemory: #{ns[:resources_used][:memory]}"
puts
puts "CPU values are in millicores (m). Memory values are in mebibytes (Mi)."
puts

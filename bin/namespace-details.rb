#!/usr/bin/env ruby

require "json"
require "pry-byebug"

# TODO: show namespace defaults (limit range)
# TODO: show totals (requested, used)
# TODO: pretty output

class Container
  attr_reader :name, :requests
  attr_accessor :used

  def initialize(args)
    @name = args.fetch(:name)
    @requests = args.fetch(:requests)
  end
end

class Pod
  attr_reader :name, :containers

  def initialize(data)
    @name = data.dig("metadata", "name")
    @containers = get_containers(data)
  end

  private

  def get_containers(data)
    data.dig("spec", "containers").map do |c|
      name = c.dig("name")
      requests = c.dig("resources", "requests")
      Container.new(name: name, requests: requests)
    end
  end
end

############################################################

def main(namespace)
  usage if namespace.nil?

  data = JSON.parse `kubectl -n #{namespace} get all -o json`
  namespace_pods = pods(data)

  usage_data = `kubectl -n court-probation-dev top pods --containers --no-headers`.chomp
  usage_data.split("\n").each { |line| add_container_usage(namespace_pods, line) }

  pp namespace_pods
end

def add_container_usage(pods, line)
  pod, container, cpu, memory = line.split(" ")
  p = pods.find { |i| i.name == pod }
  c = p.containers.find { |i| i.name == container }
  c.used = { "cpu" => cpu, "memory" => memory }
end

def pods(data)
  data.dig("items")
    .filter { |i| i.dig("kind") == "Pod" }
    .map { |pod| Pod.new(pod) }
end

def usage
  puts <<EOF

Usage: #{$0} [namespace name]

EOF
  exit
end

main ARGV.shift

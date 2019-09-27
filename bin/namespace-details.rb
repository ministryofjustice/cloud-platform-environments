#!/usr/bin/env ruby

require "json"
require "pry-byebug"

class Pod
  attr_reader :name, :containers

  def initialize(args)
    @name = args.fetch(:name)
    @containers = args.fetch(:containers)
  end
end

class Container
  attr_reader :name, :requests

  def initialize(args)
    @name = args.fetch(:name)
    @requests = args.fetch(:requests)
  end
end

def main(namespace)
  usage if namespace.nil?

  data = JSON.parse `kubectl -n #{namespace} get all -o json`
  pp pods(data)
end

def pods(data)
  pods = data.dig("items").filter { |i| i.dig("kind") == "Pod" }

  pods.map do |pod|
    name = pod.dig("metadata", "name")
    Pod.new(name: name, containers: containers(pod))
  end
end

def containers(pod)
  pod.dig("spec", "containers").map do |c|
    name = c.dig("name")
    requests = c.dig("resources", "requests")
    Container.new(name: name, requests: requests)
  end
end

def usage
  puts <<EOF

Usage: #{$0} [namespace name]

EOF
  exit
end

main ARGV.shift

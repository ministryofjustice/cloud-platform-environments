#!/usr/bin/env ruby

require "json"

module KubernetesValues
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

module FormatOutput

  private

  def format_line(title, col1, col2)
    [
      title.ljust(40),
      col1.to_s.ljust(10),
      col2.to_s.ljust(10),
    ].join
  end
end


class Namespace
  attr_reader :name, :pods, :hard, :request, :used, :limitrange

  include KubernetesValues
  include FormatOutput

  def initialize(name)
    @name = name
  end

  def get_data
    data = JSON.parse `kubectl -n #{name} get all -o json`
    @pods = get_pods(data)
    add_usage_data
    add_request_limits
    add_limit_range
    self
  end

  def to_s
    <<EOF
NAMESPACE: #{name}
  #{format_line("hard limit (cpu, memory):", hard_cpu, hard_mem)}
  #{format_line("request limit (cpu, memory):", req_cpu, req_mem)}
  #{format_line("used (cpu, memory):", used_cpu, used_mem)}
  #{format_line("per-container request (cpu, memory):", limit_cpu, limit_mem)}

PODS:
#{pods.map(&:to_s).join("\n")}
EOF
  end

  private

  def add_usage_data
    usage_data = `kubectl -n #{name} top pods --containers --no-headers`.chomp
    usage_data.split("\n").each { |line| add_container_usage(line) }

    add_used
  end

  def add_used
    used_cpu = pods.map(&:containers).flatten.inject(0) { |sum, c| sum += cpu_value(c.used.dig("cpu")) }
    used_mem = pods.map(&:containers).flatten.inject(0) { |sum, c| sum += memory_value(c.used.dig("memory")) }
    @used = { "cpu" => used_cpu, "memory" => used_mem }
  end

  def add_request_limits
    data = JSON.parse(`kubectl -n #{name} get resourcequota -o json`)
    status = data
      .dig("items")
      .first
      .dig("status")

    @hard = {
      "cpu" => status.dig("hard", "limits.cpu"),
      "memory" => status.dig("hard", "limits.memory")
    }

    @request = {
      "cpu" => status.dig("hard", "requests.cpu"),
      "memory" => status.dig("hard", "requests.memory")
    }
  end

  def add_limit_range
    data = JSON.parse(`kubectl -n #{name} get limitrange -o json`)
    @limitrange = data.dig("items")
      .first
      .dig("spec", "limits")
      .first
      .dig("defaultRequest")
  end

  def hard_mem
    memory_value hard.dig("memory")
  end

  def hard_cpu
    cpu_value hard.dig("cpu")
  end

  def req_cpu
    cpu_value request.dig("cpu")
  end

  def req_mem
    memory_value request.dig("memory")
  end

  def limit_cpu
    cpu_value limitrange.dig("cpu")
  end

  def limit_mem
    memory_value limitrange.dig("memory")
  end

  def add_container_usage(line)
    pod, container, cpu, memory = line.split(" ")
    p = pods.find { |i| i.name == pod }
    c = p.containers.find { |i| i.name == container }
    c.used = { "cpu" => cpu, "memory" => memory }
  end

  def get_pods(data)
    data.dig("items")
      .filter { |i| i.dig("kind") == "Pod" }
      .map { |pod| Pod.new(pod) }
  end

  def used_cpu
    used.dig("cpu")
  end

  def used_mem
    used.dig("memory")
  end
end

class Container
  attr_reader :name, :requests
  attr_accessor :used

  include KubernetesValues
  include FormatOutput

  def initialize(args)
    @name = args.fetch(:name)
    @requests = args.fetch(:requests)
    @used = { "cpu" => "0m", "memory" => "0Mi" }
  end

  def to_s
    <<EOF
    #{name}
      #{format_line("requested (cpu, memory):", req_cpu, req_mem)}
      #{format_line("used (cpu, memory):", used_cpu, used_mem)}
EOF
  end

  private

  def req_mem
    memory_value requests.dig("memory")
  end

  def req_cpu
    cpu_value requests.dig("cpu")
  end

  def used_cpu
    cpu_value used.dig("cpu")
  end

  def used_mem
    memory_value used.dig("memory")
  end
end

class Pod
  attr_reader :name, :containers

  def initialize(data)
    @name = data.dig("metadata", "name")
    @containers = get_containers(data)
  end

  def to_s
    <<EOF
  #{name}
#{containers.map(&:to_s).join("\n")}
EOF
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
  puts Namespace.new(namespace).get_data
end

def usage
  puts <<EOF

Usage: #{$0} [namespace name]

EOF
  exit
end

main ARGV.shift

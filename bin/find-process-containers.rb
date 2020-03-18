#!/usr/bin/env ruby

# Script to find containers/pods which are running a particular process.
# NB: this uses 'ps aux | grep [process]' so it's not going to be very
# reliable unless the process name is reasonably distinctive.

require "open3"

def main(process)
  Namespace.all.map do |namespace|
    puts
    puts namespace.name

    namespace
      .containers
      .find_all { |c| c.is_running?(process) }
      .map { |c| puts "    #{c.pod}  #{c.name}" }
  end
  puts
end

class Container
  attr_reader :namespace, :pod, :name

  def initialize(args)
    @namespace = args.fetch(:namespace)
    @pod = args.fetch(:pod)
    @name = args.fetch(:name)
  end

  def is_running?(process)
    cmd = %(kubectl -n #{namespace} exec #{pod} -c #{name} ps aux | grep #{process})
    stdout, _, _ = Open3.capture3(cmd)
    stdout.split("\n").any?
  end
end

class Namespace
  attr_reader :name

  def initialize(args)
    @name = args.fetch(:name)
  end

  def self.all
    cmd = %[kubectl get namespaces --no-headers | cut -f 1 -d' ']
    stdout, _, _ = Open3.capture3(cmd)
    stdout.split("\n").map { |ns| new(name: ns) }
  end

  def containers
    cmd = %[kubectl -n #{name} top pods --containers --no-headers]
    stdout, _, _ = Open3.capture3(cmd)
    stdout.split("\n").map do |line|
      pod, cont = line.split(" ")
      Container.new(
        namespace: name,
        pod: pod,
        name: cont
      )
    end
  end
end

############################################################

proc_name = ARGV.shift
raise "No process name supplied" if proc_name.nil?
main proc_name

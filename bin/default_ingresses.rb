#!/usr/bin/env ruby

# List ingresses and their annotations so that we can track our progress in
# moving teams to having their own, dedicated ingress controllers.

require "pry-byebug"
require "json"
require "open3"

def get_ingresses
  stdout, stderr, status = Open3.capture3("kubectl get ingresses --all-namespaces -o json")
  unless status.success?
    raise stderr
  end
  JSON.parse(stdout).fetch("items")
end

ingress_classes = get_ingresses.map { |i| i.dig("metadata", "annotations", "kubernetes.io/ingress.class") }

counts = ingress_classes.each_with_object(Hash.new(0)) { |name, hash| hash[name] += 1 }

puts counts.merge("total" => ingress_classes.size).to_json

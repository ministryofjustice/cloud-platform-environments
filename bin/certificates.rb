#!/usr/bin/env ruby

require 'json'

# Output a list of all TLS secrets in the cluster, for which there is no
# matching (i.e. with the same name) certificate object in the same namespace.
#
# When cert-manager CRDs are deleted, all  certificate objects get deleted, and
# are only recreated  if the service team redeploys to the cluster from their
# repository. This script helps to identify namespaces with this problem.

def main
  secrets = get_certificate_secrets
  certificates = get_certificate_objects

  puts %[#{"NAMESPACE".ljust(50)} #{"SECRET".ljust(50)}]
  (secrets - certificates).map do |s|
    namespace, name = s.split(":")
    puts "#{namespace.ljust(50)} #{name.ljust(50)}"
  end
end

def get_certificate_secrets
  get_data("secrets")
    .find_all { |s| s.dig("type") == "kubernetes.io/tls" }
    .map do |s|
      name = s.dig("metadata", "name")
      [get_namespace(s), name].join(":")
    end
end

def get_certificate_objects
  get_data("certificates").map { |s| [ get_namespace(s), s.dig("spec", "secretName") ].join(":") }
end

def get_data(object_type)
  JSON.parse(`kubectl get #{object_type} --all-namespaces -o json`.chomp).fetch("items")
end

def get_namespace(object)
  object.dig("metadata", "namespace")
end

main

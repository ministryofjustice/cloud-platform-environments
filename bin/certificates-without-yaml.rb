#!/usr/bin/env ruby

require "json"
require "yaml"
require "pry-byebug"

# Output a list of all certificate objects in the cluster, for which there is no
# matching certificate definition yaml file in the environments repo.
#
# When cert-manager CRDs are deleted, all  certificate objects get deleted, and
# are only recreated  if the service team redeploys to the cluster from their
# repository. This script helps to identify namespaces with this problem, so that
# we can get the teams to redeploy their certificates, and preferably move those
# yaml files into the environments repo.

def main
  certificates = get_certificate_objects
  definitions = get_certificate_definitions

  puts %(#{"NAMESPACE".ljust(50)} #{"CERT. SECRETNAME".ljust(50)})
  (certificates - definitions).map do |s|
    namespace, name = s.split(":")
    puts "#{namespace.ljust(50)} #{name.ljust(50)}"
  end
end

def get_certificate_objects
  get_data("certificates").map { |s| [get_namespace(s), s.dig("spec", "secretName")].join(":") }
end

def get_certificate_definitions
  certs = Dir[
    "namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yaml",
    "namespaces/live-1.cloud-platform.service.justice.gov.uk/*/*.yml"
  ].map { |f| certificate_definitions(f) }.flatten

  certs.map { |crt| [crt.dig("metadata", "namespace"), crt.dig("spec", "secretName")].join(":") }
end

def certificate_definitions(yaml_file)
  YAML.load_stream(File.read(yaml_file))
    .compact
    .find_all { |item| item.is_a?(Hash) }
    .find_all { |hash| hash.fetch("kind", "") == "Certificate" }
end

def get_data(object_type)
  JSON.parse(`kubectl get #{object_type} --all-namespaces -o json`.chomp).fetch("items")
end

def get_namespace(object)
  object.dig("metadata", "namespace")
end

main

#!/usr/bin/env ruby

# Given a module name (e.g. "rds-instance") report, for all namespaces, the
# namespace name, production/not, terraform resource name and module version in
# use, as CSV output.

require "open3"
require "yaml"

NAMESPACE_DIR = "namespaces/live-1.cloud-platform.service.justice.gov.uk"

def main(module_name)
  puts %(Namespace, Production, Resource name, Module version)
  namespaces.each { |ns| puts report(ns, module_name) }
end

# Returns a list of namespace directory names. This relies on our
# convention of always naming the directory the same as the namespace
def namespaces
  Dir["#{NAMESPACE_DIR}/*"]
    .find_all { |dir| FileTest.directory?(dir) }
    .map { |dir| File.basename(dir) }
end

# Return an array of CVS lines, one for each module resource defined in the
# namespace resources folder
def report(namespace, module_name)
  prod = production_or_not(namespace, module_name)

  module_tf_files(namespace, module_name).inject([]) do |lines, tf_file|
    name, version = get_resource_name_and_module_version(tf_file, module_name)
    lines << [namespace, prod, name, version].join(", ")
  end
end

# Return "true" or "false"
def production_or_not(namespace, module_name)
  yaml_file = "#{NAMESPACE_DIR}/#{namespace}/00-namespace.yaml"
  YAML.load(File.read(yaml_file))
    .dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production")
end

def module_tf_files(namespace, module_name)
  stdout, _stderr, _status = Open3.capture3("grep -l #{module_regex(module_name)} #{tfdir(namespace)}/*")
  stdout.split("\n")
end

# Takes a terraform filename, which defines an AWS resource
# and returns the (terraform) name and CP module version
def get_resource_name_and_module_version(tf_file, module_name)
  name = version = ""

  lines = File.readlines(tf_file)

  lines.grep (/module /) { |l| name = $1 if l =~ /"(.*)"/ }
  lines.grep (/#{module_regex(module_name)}/) { |l| version = $1 if l =~ /ref=(.*)"/ }

  [name, version]
end

def tfdir(namespace)
  "#{NAMESPACE_DIR}/#{namespace}/resources"
end

# NB: This only works if the version number is exactly 3 characters, e.g. "5.1"
# Also, watch out for the double backslashes - you need those, when running
# within ruby, but not if you execute the sed directly in your shell.
def module_regex(module_name)
  "github.com\\/ministryofjustice\\/cloud-platform-terraform-#{module_name}.ref=..."
end

############################################################

module_name = ARGV.shift # e.g. "rds-instance" or "s3-bucket"

main(module_name)

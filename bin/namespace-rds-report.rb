#!/usr/bin/env ruby

# For all namespaces, report the name, production/not, RDS instance name and module version

require "open3"
require "yaml"

NAMESPACE_DIR = "namespaces/live-1.cloud-platform.service.justice.gov.uk"

# NB: This only works if the version number is exactly 3 characters, e.g. "5.1"
# Also, watch out for the double backslashes - you need those, when running
# within ruby, but not if you execute the sed directly in your shell.
RDS_MODULE_REGEX = "github.com\\/ministryofjustice\\/cloud-platform-terraform-rds-instance.ref=..."

def main
  puts %(Namespace, Production, RDS name, Module version)
  namespaces.each { |ns| puts report(ns) }
end

# Returns a list of namespace directory names. This relies on our
# convention of always naming the directory the same as the namespace
def namespaces
  Dir["#{NAMESPACE_DIR}/*"]
    .find_all { |dir| FileTest.directory?(dir) }
    .map { |dir| File.basename(dir) }
end

# Return an array of CVS lines, one for each RDS instance
# defined in the namespace resources folder
def report(namespace)
  prod = production_or_not(namespace)

  rds_tf_files(namespace).inject([]) do |lines, tf_file|
    name, version = get_rds_name_and_version(tf_file)
    lines << [namespace, prod, name, version].join(", ")
  end
end

# Return "true" or "false"
def production_or_not(namespace)
  yaml_file = "#{NAMESPACE_DIR}/#{namespace}/00-namespace.yaml"
  YAML.load(File.read(yaml_file))
    .dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production")
end

def rds_tf_files(namespace)
  stdout, _stderr, _status = Open3.capture3("grep -l #{RDS_MODULE_REGEX} #{tfdir(namespace)}/*")
  stdout.split("\n")
end

# Takes a terraform filename, which defines an RDS resource
# and returns the (terraform) name and CP RDS module version
def get_rds_name_and_version(tf_file)
  name = version = ""

  lines = File.readlines(tf_file)

  lines.grep (/module /) { |l| name = $1 if l =~ /"(.*)"/ }
  lines.grep (/#{RDS_MODULE_REGEX}/) { |l| version = $1 if l =~ /ref=(.*)"/ }

  [name, version]
end

def tfdir(namespace)
  "#{NAMESPACE_DIR}/#{namespace}/resources"
end

main

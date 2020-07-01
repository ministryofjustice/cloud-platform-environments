#!/usr/bin/env ruby

# This script takes two inputs, `action` and `option`
# action: list, replace
# option: force_ssl_true, force_ssl_false, apply_pending_reboot
#
# This script can do 2 things based on the `action`
# - list all terraform files inside all directories inside NAMESPACE_DIR
#    which has force_ssl = "true", force_ssl = "false" or apply_method = "pending-reboot"
# - Replace all terraform files inside all directories inside NAMESPACE_DIR which has
#    force_ssl = "true" to remove that line
#    force_ssl = "false" to 'db_parameter = [{ name = \"rds.force_ssl\", value = \"0\", apply_method = \"immediate\" } ]'
#    apply_method = "pending-reboot" to 'db_parameter = [{ name = \"rds.force_ssl\", value = \"1\", apply_method = \"immediate\" } ]'

require "open3"
require "yaml"

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

NAMESPACE_DIR = "namespaces/live-1.cloud-platform.service.justice.gov.uk"

DB_PARAMETER_FALSE = 'db_parameter = [{ name = \"rds.force_ssl\", value = \"0\", apply_method = \"immediate\" } ]'

DB_PARAMETER_TRUE = 'db_parameter = [{ name = \"rds.force_ssl\", value = \"1\", apply_method = \"pending-reboot\" } ]'

def main(action, option)
  checkout_main
  case action
  when "list"
    namespaces.each { |ns| puts list_ns_force_ssl(ns, option) }
  when "replace"
    namespaces.each { |ns| puts update_ns_force_ssl(ns, option) }
  end
end

def checkout_main
  execute "git checkout main"
end

# Returns a list of namespace directory names. This relies on our
# convention of always naming the directory the same as the namespace
def namespaces
  Dir["#{NAMESPACE_DIR}/*"]
    .find_all { |dir| FileTest.directory?(dir) }
    .map { |dir| File.basename(dir) }
end

# Return an array of lines, one for each module resource defined in the
# namespace resources folder which has strings mentioned in the egrep
def list_ns_force_ssl(namespace, option)
  case option
  when "force_ssl_true"
    stdout, _stderr, _status = Open3.capture3("egrep -l 'force_ssl.*=.*true.*' #{tfdir(namespace)}/*")
    stdout.split("\n")
  when "force_ssl_false"
    stdout, _stderr, _status = Open3.capture3("egrep -l 'force_ssl.*=.*false.*' #{tfdir(namespace)}/*")
    stdout.split("\n")
  when "apply_pending_reboot"
    stdout, _stderr, _status = Open3.capture3("egrep -l 'apply_method.*=.*pending-reboot.*' #{tfdir(namespace)}/*")
    stdout.split("\n")
  end
end

# Return an array of lines, one for each module resource defined in the
# namespace resources folder which has
# strings mentioned in the egrep and replace with the respective replacement required
def update_ns_force_ssl(namespace, option)
  case option
  when "force_ssl_true"
    stdout, _stderr, _status = Open3.capture3("egrep -l 'force_ssl.*=.*true.*' #{tfdir(namespace)}/*")
    if stdout != ""
      `sed -i '' "s/force_ssl.*=.*true.*/ /" #{stdout}`
    end
    stdout.split("\n")
  when "force_ssl_false"
    stdout, _stderr, _status = Open3.capture3("egrep -l 'force_ssl.*=.*false.*' #{tfdir(namespace)}/*")
    if stdout != ""
      `sed -i '' "s/force_ssl.*=.*false.*/#{DB_PARAMETER_FALSE}/" #{stdout}`
    end
    stdout.split("\n")
  when "apply_pending_reboot"
    stdout, _stderr, _status = Open3.capture3("egrep -l 'apply_method.*=.*pending-reboot.*' #{tfdir(namespace)}/*")
    if stdout != ""
      `sed -i '' "s/apply_method.*=.*pending-reboot.*/#{DB_PARAMETER_TRUE}/" #{stdout}`
    end
    stdout.split("\n")
  end
end

def tfdir(namespace)
  "#{NAMESPACE_DIR}/#{namespace}/resources"
end

############################################################
action, option = ARGV
main(action, option)

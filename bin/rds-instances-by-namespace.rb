#!/usr/bin/env ruby

# iterate through terraform state files to find details of RDS instances
# output a list of namesspaces and RDS instance names

# This is to track down RDS instances which are not correctly tagged with a
# namespace name, to find out whether or not we can safely delete them

require "pry-byebug"

require "json"
require "open3"
require "tempfile"

S3_BUCKET_PATH = "s3://cloud-platform-terraform-state/cloud-platform-environments/live-1.cloud-platform.service.justice.gov.uk"
NAMESPACES_DIR = "./namespaces/live-1.cloud-platform.service.justice.gov.uk"

def main
  namespaces.each do |namespace|
    rds_instances(namespace).each { |db| puts [namespace, db].join(", ") }
  end
end

def namespaces
  Dir["#{NAMESPACES_DIR}/*"]
    .filter { |d| FileTest.directory?(d) }
    .map { |path| path.sub(/.*\//, "") }
end

def rds_instances(namespace)
  file = Tempfile.new(namespace)
  begin
    get_terraform_statefile namespace, file.path
    data = JSON.parse(File.read(file.path))
    data.dig("resources")
      .filter { |r| r["type"] == "aws_db_instance" }
      .map { |rds| rds["instances"] }.flatten
      .map { |i| i.dig("attributes", "address") }
      .map { |name| name.sub(/\..*/, "") }
  rescue
    # This probably means something went wrong with the `aws s3 cp` command.
    # Some namespaces don't have any terraform state, which will cause this
    # error.
    []
  ensure
    file.close
    file.unlink
  end
end

# Fetch the terraform state file for a namespace, and
# store it as [filename]
def get_terraform_statefile(namespace, filename)
  cmd = "aws --quiet s3 cp #{S3_BUCKET_PATH}/#{namespace}/terraform.tfstate #{filename}"
  execute cmd
end

def execute(cmd)
  # puts "executing: #{cmd}"
  stdout, stderr, status = Open3.capture3(cmd)
  unless status.success?
    $stderr.puts "Command: #{cmd} failed."
    $stderr.puts stderr
    raise
  end
  # puts stdout
  [stdout, stderr, status]
end

main

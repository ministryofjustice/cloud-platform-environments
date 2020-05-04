#!/usr/bin/env ruby

# Look for A & TXT records in the main Live-1 Route53 HostedZone, and delete
# any which do not match an existing ingress in the kubernetes cluster.
# Requires `aws` and `kubectl` commands, authorised to query the route53 API
# and the kubernetes cluster

require "open3"
require "json"
require "optparse"

LIVE1_ZONE_ID = "Z28AFU7GYHT7R4"

CLUSTER = "live-1.cloud-platform.service.justice.gov.uk"

SPECIAL_A_RECORD_NAMES = [
  CLUSTER,
  "bastion.#{CLUSTER}",
  "api.#{CLUSTER}",
  "api.internal.#{CLUSTER}",
  "apps.#{CLUSTER}"
]

BATCH_FILE = "batch.json" # We will rewrite this file before each route53 API call to delete records

def main(options)
  recordsets = fetch_resource_recordsets(LIVE1_ZONE_ID)
  keepers = required_dns_records
  records_to_delete = unneeded_txt_records(recordsets, keepers) + unneeded_a_records(recordsets, keepers)

  if options[:list_only]
    records_to_delete.each { |record| puts [record["Type"], record["Name"]].join(", ") }
  else
    records_to_delete.each_slice(100) do |records|
      delete_records(records)
      sleep 2
    end
  end
end

# Fetch all of the resource recordsets in a zone, a page at a time
def fetch_resource_recordsets(zoneid)
  next_token, recordsets = fetch_resource_recordsets_page(zoneid)

  until next_token.nil?
    next_token, list = fetch_resource_recordsets_page(zoneid, next_token)
    recordsets += list
    sleep 2 # Don't spam the route53 API - we can only make 5 calls/second total
  end

  recordsets
end

def fetch_resource_recordsets_page(zoneid, starting_token = nil, page_size = 500)
  token = starting_token.nil? ? "" : "--starting-token #{starting_token}"
  cmd = "aws route53 list-resource-record-sets --hosted-zone-id #{zoneid} --max-items #{page_size} #{token}"
  warn cmd
  json, stderr, status = Open3.capture3(cmd)
  if status.success?
    data = JSON.parse(json)
    [data["NextToken"], data["ResourceRecordSets"]]
  else
    warn stderr
    raise
  end
end

# Any A/TXT record whose name matches a name on this list should be kept
def required_dns_records
  all_ingress_hostnames + SPECIAL_A_RECORD_NAMES
end

def all_ingress_hostnames
  stdout, _, _ = Open3.capture3("kubectl get ingresses --all-namespaces -o json")
  ingresses = JSON.parse(stdout).fetch("items")
  ingresses.map { |ingress| ingress.dig("spec", "rules").map { |r| r["host"] } }.flatten.sort
end

# Any TXT record without a matching ingress hostname is not needed
def unneeded_txt_records(recordsets, keepers)
  recordsets.filter { |r| r["Type"] == "TXT" }.filter do |record|
    name = record["Name"]
      .sub(/\.$/, "") # remove extra "." from the end of the DNS record name
      .sub(/^_external_dns\./, "") # remove leading '_external_dns.'
    !keepers.include?(name)
  end
end

# Any A record without a matching ingress hostname is not needed
def unneeded_a_records(recordsets, keepers)
  recordsets.filter { |r| r["Type"] == "A" }.filter do |record|
    name = record["Name"].sub(/\.$/, "") # remove extra "." from the end of the DNS record name
    !keepers.include?(name)
  end
end

def delete_records(records)
  prepare_batch_deletion_file(records, BATCH_FILE)
  cmd = "aws route53 change-resource-record-sets --hosted-zone-id #{LIVE1_ZONE_ID} --change-batch file://#{BATCH_FILE}"
  puts cmd
  stdout, stderr, status = Open3.capture3(cmd)
  if status.success?
    puts stdout
  else
    puts stderr
  end
end

def prepare_batch_deletion_file(records, file)
  json = record_delete_batch(records).to_json
  File.write(file, json)
end

def record_delete_batch(records)
  changes = records.map { |r| record_delete_change(r) }
  {"Changes" => changes}
end

def record_delete_change(record)
  {
    "Action" => "DELETE",
    "ResourceRecordSet" => record
  }
end

def parse_options
  options = {list_only: false}

  OptionParser.new { |opts|
    opts.on("-l", "--list", "Report records that would be purged") { options[:list_only] = true }

    opts.on_tail("-h", "--help", "Show this message") do
      puts opts
      exit
    end
  }.parse!

  options
end

############################################################

main(parse_options)

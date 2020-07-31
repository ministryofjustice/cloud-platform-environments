#!/usr/bin/env ruby

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

# This script will delete completed jobs which are:
#
#   * not part of a Cronjobs
#   * and job not set with ttlSecondsAfterFinished
#
# These completed jobs pods are taking up pod counts on each node
# creating too many pods per node get alerts as (limit set by KOPS is 100 per node)
#
# NB: The script has a 'dry-run' mode, in which jobs will be listed
# but not deleted. To use this, pass the string `--dry-run` as the
# first and only argument.
#
# The script requires the following environment variables:
#
#   export PIPELINE_CLUSTER=live-1.cloud-platform.service.justice.gov.uk
#
# It also needs to be able to run:
#
#   kubectl config use-context #{cluster}
#

cluster = ENV.fetch("PIPELINE_CLUSTER")

dry_run = ARGV.shift == "--dry-run"

if dry_run
  log("green", "Dry run: detecting completed jobs in #{cluster}")
else
  log("green", "Deleting completed jobs in #{cluster}")
end

set_kube_context(cluster)

CpEnv::CompletedJobDeleter.new(dry_run: dry_run).delete

log("green", "Done.")

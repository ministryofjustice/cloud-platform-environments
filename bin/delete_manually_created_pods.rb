#!/usr/bin/env ruby

require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

# This script will delete any pods which are:
#
#   * not part of a ReplicaSet
#   * and not in kube-system
#   * and have been running for more than 2 days
#
# Such pods prevent the node-recycler from draining a node to
# replace it.
#
# NB: The script has a 'dry-run' mode, in which pods will be listed
# but not deleted. To use this, pass the string `--dry-run` as the
# first and only argument.
#
# Developers need to run manual pods for tasks such as port-forwarding
# to a database, but there's no good reason for such a pod to still be
# running after 48 hours. If pods should always be running, they should
# be part of a deployment (and hence a ReplicaSet).
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
  log("green", "Dry run: detecting manually created pods in #{cluster}")
else
  log("green", "Deleting manually created pods in #{cluster}")
end

set_kube_context(cluster)

CpEnv::ManuallyCreatedPodDeleter.new(dry_run: dry_run).run

log("green", "Done.")

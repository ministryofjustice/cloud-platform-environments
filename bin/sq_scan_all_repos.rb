#!/usr/bin/env ruby
#require 'pry-byebug'
require File.join(".", File.dirname(__FILE__), "..", "lib", "cp_env")

cluster = ENV.fetch("PIPELINE_CLUSTER")

dry_run = ARGV.shift == "--dry-run"



set_kube_context(cluster)

CpEnv::SonarQubeScanner.new(dry_run: dry_run).scan_all_repos
#binding.pry

log("green", "Done.")

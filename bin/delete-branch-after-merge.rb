#!/usr/bin/env ruby

require "json"
require "octokit"

require File.join(".", File.dirname(__FILE__), "lib", "github")

puts "Merged PR: #{pr_number}"
puts "Deleting branch: #{branch}"
github.delete_branch(repo, branch)

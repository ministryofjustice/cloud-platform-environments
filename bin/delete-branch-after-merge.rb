#!/usr/bin/env ruby

require "json"
require "octokit"

require File.join(".", File.dirname(__FILE__), "lib", "github")

puts "Merged PR: #{pr_number}"
puts "Deleting branch: #{branch}"

begin
  github.delete_branch(repo, branch)
rescue Octokit::UnprocessableEntity
  puts "Branch not found; already deleted?"
end

#!/usr/bin/env ruby

require "json"
require "octokit"

require File.join(".", File.dirname(__FILE__), "lib", "github")

def terraform_fmt
  terraform_directories_in_pr.each do |dir|
    execute "terraform fmt #{dir}"
  end
end

def terraform_directories_in_pr
  terraform_files_in_pr
    .map { |f| File.dirname(f) }
    .sort
    .uniq
end

def terraform_files_in_pr
  files_in_pr.grep(/\.tf$/)
end

############################################################

terraform_fmt

files = modified_files

if files.any?
  puts "Committing changes to:\n  #{files.join("\n  ")}"
  commit_files(branch, files, "Fixed formatting using terraform fmt")
end

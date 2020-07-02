#!/usr/bin/env ruby

# Script to output a CSV list of namespaces and their creation date.  To use,
# install all the gems, and then invoke this script from the root of a current
# working copy of the cloud-platform-environments repo.
#
# To get namespaces created by month, do this with the output:
#
#     cat repos.csv | sed 's/-.. .*//' | sort | uniq -c
#

require "git"
require "logger"
require "yaml"

class NamespaceAddition
  attr_reader :date, :namespace, :author, :commit_id

  def initialize(args)
    @date = args.fetch(:date)
    @namespace = args.fetch(:namespace)
    @author = args.fetch(:author)
    @commit_id = args.fetch(:commit_id)
  end
end

ADD_FILE = "new" # DiffFile.type == "new" when adding a file
NAMESPACE_REGEX = %r[^namespaces/live-1.cloud-platform.service.justice.gov.uk/(.*)/00-namespace.yaml$]
MERGE_REGEX = %r[^Merge ]

def main
  namespaces_added = []

  git = Git.open(".")

  raise "Please run this script in an up to date copy of the main branch" unless git.current_branch == "main"

  # TODO iterate through *full* history programmatically.
  #      Currently we just look a the last 5000 commits.
  git.log(5000).each do |commit|
    next if commit.parent.nil?

    namespace = namespace_added_by_commit(git, commit)

    if !namespace.nil?
      namespaces_added << NamespaceAddition.new(
        date: commit.date,
        author: commit.author.email,
        namespace: namespace,
        commit_id: commit.objectish,
      )
    end
  rescue ArgumentError
    # Some commit around 2370 ago causes this error:
    # ...git-1.5.0/lib/git/diff.rb:135:in `split': invalid byte sequence in UTF-8 (ArgumentError)
    # I'm rescuing it so that I can do a full scan of the repository history (barring the one
    # commit that causes problems)
  end

  namespaces_added.each do |ns|
    puts [ns.date, ns.namespace, ns.author, ns.commit_id, is_production?(ns.namespace)].join(", ")
  end
end

def is_production?(namespace)
  obj = YAML.load(File.read "namespaces/live-1.cloud-platform.service.justice.gov.uk/#{namespace}/00-namespace.yaml")
  obj.dig("metadata", "labels", "cloud-platform.justice.gov.uk/is-production") == "true"
rescue
  false
end

def namespace_added_by_commit(git, commit)
  # Both the 'real' commit and the merge commit will be
  # identified as having added the namespace. We ignore
  # the merge commits, so each addition is only counted
  # once.
  #
  # This means we might be counting the addition too early,
  # since we're taking the date of the commit, rather than
  # the date the PR was merged, but we can probably live
  # with that.
  return if is_merge?(commit)

  diff = git.diff(commit.parent.objectish, commit.objectish)

  diff.each do |diff_file|

    # This may also be true for deletions. It's unclear, but checking the
    # output of the script, it only reports additions, so probably some
    # other part of the filtering is suppressing commits that *delete*
    # a namespace.
    next unless diff_file.type == ADD_FILE

    if NAMESPACE_REGEX.match(diff_file.path)
      return $1
    end
  end

  nil
rescue
  nil
end

def is_merge?(commit)
  !!MERGE_REGEX.match(commit.message)
end

main

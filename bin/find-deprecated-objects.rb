#!/usr/bin/env ruby

# Identify kubernetes objects in the current cluster which use deprecated API
# versions which are not supported in kubernetes 1.16
#
# https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.16.md#deprecations-and-removals
# https://www.ibm.com/cloud/blog/announcements/kubernetes-version-1-16-removes-deprecated-apis

require "json"
require "open3"

DEPRECATED_API_VERSIONS = %w[extensions/v1beta1 apps/v1beta1 apps/v1beta2]

def main
  puts "Kind, APIVersion, Name, Namespace, Team, Repo"

  namespaces = namespace_details

  deprecated_api_objects.each do |obj|
    puts object_csv(obj, namespaces)
  end

  stdout, _, _ = Open3.capture3("kubectl get pods --all-namespaces -o json")
  # stdout = File.read("pods.json")

  # TODO filter for tiller < 2.16.3
  JSON.parse(stdout).fetch("items")
    .filter { |pod| tiller?(pod) }
    .map { |pod| puts tiller_csv(pod, namespaces) }
end

def tiller?(pod)
  pod.dig("spec", "containers").any? { |c| /tiller/.match(c.fetch("image")) }
end

def tiller_version(pod)
  pod.dig("spec", "containers")
    .map { |c| c.fetch("image") }
    .first
    .sub(/.*tiller:/, "")
end

# Pre-fetch namespace details: owning team & github repo
# returns a hash: namespace_name => { team: team, repo: repo }
def namespace_details
  stdout, _, _ = Open3.capture3("kubectl get namespaces -o json")
  # stdout = File.read("namespaces.json")

  # build a hash of namespaces & their github repos
  rtn = JSON.parse(stdout).fetch("items").each_with_object({}) { |ns, hash|
    name = ns.dig("metadata", "name")
    repo = ns.dig("metadata", "annotations", "cloud-platform.justice.gov.uk/source-code")
    hash[name] = {repo: repo}
  }

  # add owning teams, from rolebindings
  stdout, _, _ = Open3.capture3("kubectl get rolebindings --all-namespaces -o json")
  # stdout = File.read("rolebindings.json")

  JSON.parse(stdout).fetch("items").each do |rb|
    namespace = rb.dig("metadata", "namespace")
    team = rb.fetch("subjects").first.fetch("name")
    if /github:/.match?(team)
      rtn[namespace][:team] = team.sub("github:", "")
    end
  end

  rtn
end

def deprecated_api_objects
  # NB: double backslashes, compared to running the command from a terminal
  cmd = %(
    kubectl get NetworkPolicy,PodSecurityPolicy,DaemonSet,Deployment,ReplicaSet --all-namespaces
    -o 'jsonpath={range.items[*]}{.metadata.annotations.kubectl\\.kubernetes\\.io/last-applied-configuration}{"\\n"}{end}'
  ).tr("\n", " ").strip

  stdout, _, _ = Open3.capture3(cmd)
  # stdout = File.read("objects.json")

  objects = stdout.split("\n").map { |line|
    next if line == ""
    JSON.parse(line)
  }.compact

  objects.filter { |obj| DEPRECATED_API_VERSIONS.include?(obj.fetch("apiVersion")) }
end

# Given a hash representing a kubernetes object, return a csv of the fields we
# care about wrt. the API deprecation
def object_csv(hash, namespaces)
  namespace, team, repo = namespace_team_repo(hash, namespaces)

  [
    hash.fetch("kind"),
    hash.fetch("apiVersion"),
    hash.dig("metadata", "name"),
    namespace,
    team,
    repo,
  ].join(", ")
end

def tiller_csv(pod, namespaces)
  namespace, team, repo = namespace_team_repo(pod, namespaces)

  [
    "tiller",
    tiller_version(pod),
    pod.dig("metadata", "name"),
    namespace,
    team,
    repo,
  ].join(", ")
end

def namespace_team_repo(hash, namespaces)
  namespace = hash.dig("metadata", "namespace")

  ns = namespaces[namespace]
  team = ns.nil? ? "" : ns[:team]
  repo = ns.nil? ? "" : ns[:repo]

  [namespace, team, repo]
end

############################################################

main

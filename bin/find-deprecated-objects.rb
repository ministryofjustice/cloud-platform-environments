#!/usr/bin/env ruby

# Identify kubernetes objects in the current cluster which use deprecated API
# versions which are not supported in kubernetes 1.16
#
# https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.16.md#deprecations-and-removals
# https://www.ibm.com/cloud/blog/announcements/kubernetes-version-1-16-removes-deprecated-apis

require "json"
require "open3"

OBJECT_TYPES = %w[
  DaemonSet
  Deployment
  Ingress
  NetworkPolicy
  PodSecurityPolicy
].join(",")

DEPRECATED_API_VERSIONS = %w[extensions/v1beta1 apps/v1beta1 apps/v1beta2]

def main
  puts "Kind, APIVersion, Name, Namespace, Team, Repo"

  namespaces = namespace_details

  deprecated_api_objects.each do |obj|
    puts object_csv(obj, namespaces)
  end


  # TODO filter for tiller < 2.16.3
  tiller_pods = parsed_json_output("kubectl get pods --all-namespaces -o json").fetch("items", [])
    .filter { |pod| tiller?(pod) }
  tiller_pods.map { |pod| puts tiller_csv(pod, namespaces) }
  output_helm2_object_data(tiller_pods)
end

def output_helm2_object_data(tiller_pods)
  tiller_pod_namespaces = tiller_pods
    .map { |pod| pod.dig("metadata", "namespace") }
    .sort
    .uniq


  tiller_pod_namespaces.each do |ns|
    helm2_deprecated_objects(ns).each do |obj|
      puts helm_object_csv(obj, namespaces)
    end
  end
end

def helm_object_csv(object, namespaces)
  team, repo = namespace_team_repo(object[:namespace], namespaces)
  [
    object[:kind],
    object[:api_version],
    object[:name],
    object[:namespace],
    team,
    repo
  ].join(", ")
end

def helm2_deprecated_objects(namespace)
  # NB: takes approx 40 seconds to run
  cmd = %(pluto detect-helm --namespace #{namespace} --helm-version 2 -o json)
  parsed_json_output(cmd).fetch("items", []).map do |obj|
    # 'name' is often something like "check-financial-eligibility/check-financial-eligibility"
    # so if it matches that pattern, simplify it.
    name = obj.fetch("name")
    /(.*)\/\1/.match(name) && name = $1

    {
      name: name,
      namespace: obj.fetch("namespace"),
      api_version: obj.dig("api", "version"),
      kind: obj.dig("api", "kind"),
    }
  end
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
  # build a hash of namespaces & their github repos
  rtn = parsed_json_output("kubectl get namespaces -o json")
    .fetch("items", []).each_with_object({}) { |ns, hash|
      name = ns.dig("metadata", "name")
      repo = ns.dig("metadata", "annotations", "cloud-platform.justice.gov.uk/source-code")
      hash[name] = {repo: repo}
    }

  # add owning teams, from rolebindings
  parsed_json_output("kubectl get rolebindings --all-namespaces -o json").fetch("items", []).each do |rb|
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
  cmd = "kubectl get #{OBJECT_TYPES} --all-namespaces -o json"

  parsed_json_output(cmd).fetch("items", [])
    .filter { |obj| last_applied_api_version(obj) }
    .filter { |obj| uses_deprecated_apis?(obj) }
end

def uses_deprecated_apis?(obj)
  api_version = last_applied_api_version(obj)
  DEPRECATED_API_VERSIONS.include?(api_version)
end

def last_applied_api_version(obj)
  json = obj.dig("metadata", "annotations", "kubectl.kubernetes.io/last-applied-configuration")
  json.nil? ? false : JSON.parse(json).fetch("apiVersion")
end

# Given a hash representing a kubernetes object, return a csv of the fields we
# care about wrt. the API deprecation
def object_csv(hash, namespaces)
  namespace = hash.dig("metadata", "namespace")
  team, repo = namespace_team_repo(namespace, namespaces)

  [
    hash.fetch("kind"),
    hash.fetch("apiVersion"),
    hash.dig("metadata", "name"),
    namespace,
    team,
    repo
  ].join(", ")
end

def tiller_csv(pod, namespaces)
  namespace = pod.dig("metadata", "namespace")
  team, repo = namespace_team_repo(namespace, namespaces)

  [
    "tiller",
    tiller_version(pod),
    pod.dig("metadata", "name"),
    namespace,
    team,
    repo
  ].join(", ")
end

def namespace_team_repo(namespace, namespaces)
  ns = namespaces[namespace]
  team = ns.nil? ? "" : ns[:team]
  repo = ns.nil? ? "" : ns[:repo]

  [team, repo]
end

def parsed_json_output(cmd)
  stdout, stderr, status = Open3.capture3(cmd)
  $stderr.puts(stderr) unless status.success?
  JSON.parse(stdout)
rescue JSON::ParserError
  $stderr.puts("JSON::ParserError parsing:\n#{stdout}")
  {}
end


############################################################

main

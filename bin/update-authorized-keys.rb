#!/usr/bin/env ruby

# Fetch Public ssh keys of all members of "webops",
# build the authorized_keys.txt file and
# create a PR for the file

require "json"
require "net/http"
require "open3"
require "uri"
require "base64"
require "securerandom"

ORG = "ministryofjustice"
TEAM_NAME = "webops"
REPO_NAME = "https://github.com/ministryofjustice/cloud-platform-terraform-bastion"

GITHUB_GRAPHQL_API_URL = "https://api.github.com/graphql"

GITHUB_REST_API_URL = "https://api.github.com/repos/ministryofjustice/cloud-platform-terraform-bastion"

BRANCH = SecureRandom.alphanumeric

# Build the autorized_keys file for the given organisation and team,
# create a branch with random alphanumeric on the cloud-platform-terraform-bastion repo,
# and create a commit to replace the existing file authorized_keys.txt with the newly generated one
# Lastly create a Pull Request against the newly created branch and the commit.

def main
  authorized_keys = build_authorized_keys

  content_sha, encoded_authorized_keys = compare_with_existing_keys(authorized_keys)

  if encoded_authorized_keys.nil?
    puts "No new publicKeys to raise PR"
  else
    create_new_branch_commit(content_sha, encoded_authorized_keys)
    puts create_pull_request
  end
end

def build_authorized_keys
  json = post_query(
    json: {query: get_publickeys_query}.to_json,
    token: ENV.fetch("GITHUB_TOKEN"),
    api_url: GITHUB_GRAPHQL_API_URL
  )
  members = JSON.parse(json)
    .dig("data", "organization", "team", "members", "nodes")

  authorized_keys = ""
  members.each do |member|
    authorized_keys += "# " + format(member["name"]) + "\n"
    member["publicKeys"]["edges"].each do |node|
      authorized_keys += node["node"]["key"] + " @" + format(member["login"]) + "\n"
    end
  end

  authorized_keys
end

def compare_with_existing_keys(authorized_keys)
  # Get the latest blob for the content
  api_url = GITHUB_REST_API_URL + "/contents/files/authorized_keys.txt"

  json = get_query(
    token: ENV.fetch("GITHUB_TOKEN"),
    api_url: api_url
  )

  content = JSON.parse(json).dig("content")

  decoded_authorized_keys = Base64.decode64(content)

  if decoded_authorized_keys == authorized_keys
    nil
  else
    content_sha = JSON.parse(json).dig("sha")
    encoded_authorized_keys = Base64.strict_encode64(authorized_keys)
    [encoded_authorized_keys, content_sha]
  end
end

def create_new_branch_commit(content_sha, encoded_authorized_keys)
  # Get the main branch sha
  json = get_query(
    token: ENV.fetch("GITHUB_TOKEN"),
    api_url: GITHUB_REST_API_URL + "/git/ref/heads/main"
  )

  sha = JSON.parse(json).dig("object", "sha")

  # Create a reference which is basically creating a branch
  json = post_query(
    json: get_create_branch_query(sha),
    token: ENV.fetch("GITHUB_TOKEN"),
    api_url: GITHUB_REST_API_URL + "/git/refs"
  )

  # Send the PUT request with the encoded authorized_key content
  json = put_query(
    json: get_update_content_query(content_sha, encoded_authorized_keys),
    token: ENV.fetch("GITHUB_TOKEN"),
    api_url: api_url
  )
end

def create_pull_request
  json = post_query(
    json: get_pull_request_query,
    token: ENV.fetch("GITHUB_TOKEN"),
    api_url: GITHUB_REST_API_URL + "/pulls"
  )
end

def get_query(params)
  token = params.fetch(:token)
  url = params.fetch(:api_url)

  headers = {"Authorization" => "bearer #{token}"}

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  response = http.get(uri.request_uri)
  code = response.code
  raise "Response code #{code}" unless code == "200"
  response.body
end

def post_query(params)
  token = params.fetch(:token)
  json = params.fetch(:json)
  url = params.fetch(:api_url)

  headers = {"Authorization" => "bearer #{token}"}

  uri = URI.parse(url)
  resp = Net::HTTP.post(uri, json, headers)
  resp.body
end

def put_query(params)
  token = params.fetch(:token)
  json = params.fetch(:json)
  url = params.fetch(:api_url)

  headers = {"Authorization" => "bearer #{token}"}

  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Put.new(uri)
  req["Accept"] = "application/vnd.github.v3+json",
    req["Authorization"] = "bearer #{token}"
  req.body = json
  response = http.request(req)
  code = response.code
  raise "Response code #{response.body} #{code}" unless code == "200"
  response.body
end

def get_pull_request_query
  %(
    {
        "title": "Update authorized keys for bastion with all team member of webops",
        "head": "#{BRANCH}",
        "base": "main"
    }
)
end

def get_update_content_query(sha, encoded_authorized_keys)
  %(
        {
            "message": "Updating auth keys for all team members",
            "content": "#{encoded_authorized_keys}",
            "sha": "#{sha}",
            "branch": "#{BRANCH}"
        }
    )
end

def get_create_branch_query(sha)
  %(
    {
        "ref": "refs/heads/#{BRANCH}",
        "sha": "#{sha}"
    }
)
end

def get_repository_query
  owner, name = REPO_NAME.sub("https://github.com/", "").split("/")
  %[
      {
        repository(owner: "#{owner}", name: "#{name}") {
          id
      }
    }
    ]
end

def get_publickeys_query
  %[
    {
        organization(login: "#{ORG}") {
            team(slug: "#{TEAM_NAME}") {
            id
            members {
                nodes {
                id
                login
                name
                publicKeys(first: 10) {
                    edges {
                    node {
                        key
                    }
                    }
                }
                }
            }
            }
        }
    }
  ]
end

############################################################

main

variable "cluster" {
  description = "What cluster are you deploying your namespace. I.E cloud-platform-test-1 "
  default = "cloud-platform-live-0"
}

variable "namespace" {
  description = "Namespace you would like to create on cluster <application>-<environment>. I.E myapp-dev"
}

variable "github_team" {
  description = "This is your team name as defined by the GITHUB api. This has to match the team name on the Github API"
}

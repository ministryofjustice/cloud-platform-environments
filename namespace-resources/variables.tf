variable "cluster" {
  description = "What cluster are you deploying your namespace. I.E cloud-platform-test-1 "
}

variable "namespace" {
  description = "Namespace you would like to create on cluster <application>-<environment>. I.E myapp-dev"
}

variable "github_team" {
  description = "Your github team"
}

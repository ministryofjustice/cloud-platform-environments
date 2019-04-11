variable "cluster" {
  description = "What cluster are you deploying your namespace. I.E cloud-platform-test-1 "
  default     = "live-1.cloud-platform"
}

variable "namespace" {
  description = "Namespace you would like to create on cluster <application>-<environment>. I.E myapp-dev"
}

variable "github_team" {
  description = "This is your team name as defined by the GITHUB api. This has to match the team name on the Github API"
}

variable "business-unit" {
  description = " Area of the MOJ responsible for the service"
}

variable "is-production" {
  default = "false"
}

variable "environment" {}

variable "application" {}

variable "owner" {
  description = "Who is the owner/Who is responsible for this application"
}

variable "contact_email" {
  description = "Contact email address for owner of the application"
}

variable "source_code_url" {
  description = "Url of the source code for your application"
}

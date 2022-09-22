/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {
}

variable "vpc_name" {
}


variable "namespace" {
  default = "track-a-query-production"
}

variable "domain" {
  default = "track-a-query.service.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

variable "application" {
  default = "track-a-query"
}

variable "infrastructure-support" {
  default = "correspondence-support@digital.justice.gov.uk"
}

variable "team_name" {
  default = "correspondence"
}


variable "cluster_state_bucket" {
}

variable "kubernetes_cluster" {
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "repo_name" {
  default = "correspondence_tool_staff"
}

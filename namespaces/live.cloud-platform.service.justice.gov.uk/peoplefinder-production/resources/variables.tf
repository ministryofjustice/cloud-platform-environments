/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}

variable "vpc_name" {
}

variable "namespace" {
  default = "peoplefinder-production"
}

variable "domain" {
  default = "peoplefinder.service.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

variable "application" {
  default = "peoplefinder"
}

variable "infrastructure-support" {
  default = "people-finder-support@digital.justice.gov.uk"
}

variable "team_name" {
  default = "peoplefinder"
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
  default = "peoplefinder"
}

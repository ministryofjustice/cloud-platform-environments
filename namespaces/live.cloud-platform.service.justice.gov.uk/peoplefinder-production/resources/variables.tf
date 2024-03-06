/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "peoplefinder-production"
}

variable "business_unit" {
  default = "Central Digital"
}

variable "application" {
  default = "peoplefinder"
}

variable "domain" {
  default = "peoplefinder.service.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "environment" {
  default = "production"
}

variable "infrastructure_support" {
  default = "people-finder-support@digital.justice.gov.uk"
}

variable "team_name" {
  default = "peoplefinder"
}

variable "eks_cluster_name" {
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

variable "kubernetes_cluster" {}

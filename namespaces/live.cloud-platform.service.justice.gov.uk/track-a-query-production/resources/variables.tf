/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}


variable "namespace" {
  default = "track-a-query-production"
}

variable "domain" {
  default = "track-a-query.service.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "environment" {
  default = "production"
}

variable "application" {
  default = "track-a-query"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "correspondence@digital.justice.gov.uk"
}

variable "team_name" {
  default = "correspondence"
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
  default = "correspondence_tool_staff"
}

variable "business_unit" {
  default = "Central Digital"
}

variable "kubernetes_cluster" {}

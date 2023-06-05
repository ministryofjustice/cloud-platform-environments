/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}

variable "namespace" {
  default = "contact-moj-production"
}

variable "domain" {
  default = "contact-moj.service.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
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
  default = "correspondence_tool_public"
}

variable "team_name" {
  default = "correspondence"
}

variable "business_unit" {
  default = "Central Digital"
}

variable "application" {
  default = "contact-moj"
}

variable "infrastructure_support" {
  default = "correspondence@digital.justice.gov.uk"
}


variable "team_name" {
  default = "move-a-prisoner"
}

variable "environment-name" {
  default = "staging"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "moveaprisoner@digital.justice.gov.uk"
}

variable "application" {
  default = "HMPPS Book a secure move frontend"
}

variable "namespace" {
  default = "hmpps-book-secure-move-frontend-staging"
}

variable "repo_name" {
  default = "hmpps-book-secure-move-frontend"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}

variable "business_unit" {
  default = "HMPPS"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}
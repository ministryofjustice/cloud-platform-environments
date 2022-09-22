variable "application" {
  default = "Parliamentary Questions Tracker"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "environment-name" {
  default = "development"
}

variable "infrastructure-support" {
  default = "Tactical Products Team: pqsupport@digital.justice.gov.uk"
}

variable "is-production" {
  default = false
}

variable "namespace" {
  default = "parliamentary-questions-development"
}

variable "repo_name" {
  default = "parliamentary-questions"
}

variable "team_name" {
  default = "pq-team"
}

// The following two variables are provided at runtime by the pipeline.
variable "vpc_name" {
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}
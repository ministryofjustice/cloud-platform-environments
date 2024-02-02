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
  default = "staging"
}

variable "infrastructure_support" {
  default = "Tactical Products Team: pqsupport@digital.justice.gov.uk"
}

variable "is_production" {
  default = false
}

variable "namespace" {
  default = "parliamentary-questions-staging"
}

variable "team_name" {
  default = "pq-team"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}
variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}


variable "kubernetes_cluster" {}

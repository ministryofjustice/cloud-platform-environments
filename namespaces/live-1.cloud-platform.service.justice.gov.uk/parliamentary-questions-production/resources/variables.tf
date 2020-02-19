variable "application" {
  default = "Parliamentary Questions Tracker"
}

variable "aws_region" {
  default = "eu-west-2"
}

variable "db_backup_retention_period" {
  default = "7"
}

variable "environment-name" {
  default = "production"
}

variable "infrastructure-support" {
  default = "Tactical Products Team: pqsupport@digital.justice.gov.uk"
}

variable "is-production" {
  default = true
}

variable "namespace" {
  default = "parliamentary-questions-production"
}

variable "repo_name" {
  default = "parliamentary-questions"
}

variable "team_name" {
  default = "pq-team"
}

variable "domain" {
  default = "trackparliamentaryquestions.service.gov.uk"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

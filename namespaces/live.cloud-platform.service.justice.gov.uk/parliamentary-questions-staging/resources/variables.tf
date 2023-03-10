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

variable "infrastructure-support" {
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

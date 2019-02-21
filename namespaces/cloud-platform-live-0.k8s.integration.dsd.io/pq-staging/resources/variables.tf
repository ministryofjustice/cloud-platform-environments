variable "team_name" {
  default = "pq-team"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "environment-name" {
  default = "staging"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "Parliamentary Questions: pq@digital.justice.gov.uk"
}

variable "application" {
  default = "Parliamentary Questions Tracker"
}

variable "namespace" {
  default = "pq-staging"
}

variable "repo_name" {
  default = "parliamentary-questions"
}

variable "aws_region" {
  default = "eu-west-1"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {}

variable "cluster_state_bucket" {}

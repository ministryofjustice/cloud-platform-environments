variable "team_name" {
  default = "parliamentary-questions"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "environment-name" {
  default = "dev"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "Parliamentary Questions: pq@digital.justice.gov.uk"
}

variable "application" {
  default = "Track Parliamentary Questions"
}

variable "namespace" {
  default = "pq-dev"
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

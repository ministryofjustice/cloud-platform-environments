variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "staging"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "PECS move platform backend"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-staging"
}

variable "dev_namespace" {
  default = "hmpps-book-secure-move-api-dev"
}

variable "repo_name" {
  default = "hmpps-book-secure-move-api"
}

variable "backup_window" {
  default = "22:00-23:59"
}

variable "maintenance_window" {
  default = "sun:00:00-sun:03:00"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "production"
}

variable "is-production" {
  default = "true"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure-support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "HMPPS Book a secure move frontend"
}

variable "namespace" {
  default = "hmpps-book-secure-move-frontend-production"
}

variable "repo_name" {
  default = "hmpps-book-secure-move-frontend"
}

// The following two variables are provided at runtime by the pipeline.
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}


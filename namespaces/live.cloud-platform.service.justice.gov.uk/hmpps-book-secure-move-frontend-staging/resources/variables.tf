variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "staging"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
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

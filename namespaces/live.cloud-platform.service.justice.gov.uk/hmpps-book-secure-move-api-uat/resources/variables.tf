variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "uat"
}

variable "is-production" {
  default = "false"
}

variable "infrastructure-support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "HMPPS Book a secure move API"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-uat"
}

variable "repo_name" {
  default = "hmpps-book-secure-move-api"
}

variable "business-unit" {
  default = "Digital and Technology"
}

variable "domain" {
  default = "bookasecuremove.service.justice.gov.uk"
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

variable "vpc_name" {
}

variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "production"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure-support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "HMPPS Book a secure move API"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-production"
}

variable "business_unit" {
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

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}

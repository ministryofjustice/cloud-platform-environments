variable "environment-name" {
  default = "staging"
}

variable "team_name" {
  default = "prison-visits-booking"
}

variable "is_production" {
  default = "false"
}

variable "namespace" {
  default = "prison-visits-booking-staging"
}

variable "infrastructure_support" {
  default = "pvb-technical-support@digital.justice.gov.uk"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "prison-visits-booking-staff"
}

variable "number_cache_clusters" {
  default = "2"
}

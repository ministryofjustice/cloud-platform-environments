variable "application" {
  default = "hmpps-submit-information-report"
}

variable "namespace" {
  default = "hmpps-submit-information-report-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "digital-prison-services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

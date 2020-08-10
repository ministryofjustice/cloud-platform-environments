variable "domain_psi" {
  default = "probation-search-indexer.hmpps.service.justice.gov.uk"
}

variable "domain_pos" {
  default = "probation-offender-search.hmpps.service.justice.gov.uk"
}

variable "application" {
  default = "probation-offender-search-indexer"
}

variable "namespace" {
  default = "probation-offender-search-prod"
}

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}


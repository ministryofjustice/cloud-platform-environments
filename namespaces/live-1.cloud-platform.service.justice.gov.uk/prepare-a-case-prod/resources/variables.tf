variable "domain" {
  default = "prepare-case-probation.service.justice.gov.uk"
}

variable "application" {
  default = "prepare-a-case"
}

variable "namespace" {
  default = "prepare-a-case-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Probation in court"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-in-court-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "number_cache_clusters" {
  default = "3"
}


variable "prepare-case-domain" {
  default = "prepare-case-probation.service.justice.gov.uk"
}

variable "crime-portal-mirror-gateway-domain" {
  default = "crime-portal-mirror-gateway-probation.service.justice.gov.uk"
}

variable "application" {
  default = "prepare-a-case"
}

variable "namespace" {
  default = "court-probation-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-in-court"
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

variable "is_production" {
  default = "true"
}

variable "rds-family" {
  default = "postgres11"
}

variable "db_engine_version" {
  default = "11"
}

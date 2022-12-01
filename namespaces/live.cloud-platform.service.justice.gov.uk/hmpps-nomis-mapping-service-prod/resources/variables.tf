variable "domain" {
  default = "nomis-sync-prisoner-mapping.hmpps.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-nomis-mapping-service-prod"
}

variable "namespace" {
  default = "hmpps-nomis-mapping-service-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "syscon-devs"
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

variable "rds-family" {
  default = "postgres14"
}


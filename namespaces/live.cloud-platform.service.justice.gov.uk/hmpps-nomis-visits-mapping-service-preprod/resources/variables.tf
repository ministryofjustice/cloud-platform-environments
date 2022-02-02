variable "domain" {
  default = "nomis-visits-mapping-preprod.hmpps.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-nomis-visits-mapping-service-preprod"
}

variable "namespace" {
  default = "hmpps-nomis-visits-mapping-service-preprod"
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
  default     = "preprod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "rds-family" {
  default = "postgres14"
}


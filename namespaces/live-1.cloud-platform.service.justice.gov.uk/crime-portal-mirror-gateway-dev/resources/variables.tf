variable "application" {
  default = "court-case-service"
}

variable "namespace" {
  default = "crime-portal-mirror-gateway-dev"
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
  default     = "dev"
}

variable "zone-name" {
  default = "crime-portal-mirror-gateway.service.justice.gov.uk"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-in-court-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "rds-family" {
  default = "postgres10"
}



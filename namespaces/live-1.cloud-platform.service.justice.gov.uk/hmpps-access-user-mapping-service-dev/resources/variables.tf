variable "application" {
  default = "hmpps-access-user-mapping-service"
}

variable "namespace" {
  default = "hmpps-access-user-mapping-service-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-access"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-digital-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}


variable "domain" {
  default = "restricted-patients-api-dev.hmpps.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-restricted-patients-api"
}

variable "namespace" {
  default = "hmpps-restricted-patients-api-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital Prison Services/New Nomis"
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


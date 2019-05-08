variable "domain" {
  default = "nomis-api-access.service.justice.gov.uk"
}

variable "application" {
  default = "nomis-api-access"
}

variable "namespace" {
  default = "nomis-api-access-production"
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
  default     = "production"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "matt.whittaker@digtal.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "application" {
  default = "delius oauth2 server"
}

variable "namespace" {
  default = "court-probation-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "jaspal.panesar@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "rds-family" {
  default = "postgres10"
}

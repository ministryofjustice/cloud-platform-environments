variable "domain" {
  default = "prison-to-probation-update-dev.prison.service.justice.gov.uk"
}

variable "application" {
  default = "prison-to-probation-update"
}

variable "namespace" {
  default = "prison-to-probation-update-dev"
}


variable "vpc_name" {
}


variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps-tech"
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


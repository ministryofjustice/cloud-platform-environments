variable "domain" {
  default = "offender-events.prison.service.justice.gov.uk"
}

variable "application" {
  default = "offender-events"
}

variable "namespace" {
  default = "offender-events-prod"
}


variable "vpc_name" {
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

variable "github_token" {
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

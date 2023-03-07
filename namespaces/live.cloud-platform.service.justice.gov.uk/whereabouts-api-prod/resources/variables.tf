variable "domain" {
  default = "whereabouts-api.service.justice.gov.uk"
}

variable "application" {
  default = "whereabouts-api"
}

variable "namespace" {
  default = "whereabouts-api-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps-core"
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

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "dps_adjudications"
}

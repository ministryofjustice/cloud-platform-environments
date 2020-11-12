variable "application" {
  default = "probation-tiering"
}

variable "namespace" {
  default = "probation-tiering-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Manage a Sentence Team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

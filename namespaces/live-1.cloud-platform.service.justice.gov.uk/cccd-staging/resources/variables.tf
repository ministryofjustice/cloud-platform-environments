variable "application" {
  default = "cccd"
}

variable "namespace" {
  default = "cccd-staging"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-get-paid"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "crowncourtdefence@digtal.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

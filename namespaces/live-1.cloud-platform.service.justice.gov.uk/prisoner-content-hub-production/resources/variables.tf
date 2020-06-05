variable "domain" {
  default = "content-hub.prisoner.service.justice.gov.uk/ "
}

variable "application" {
  default = "prisoner-content-hub"
}

variable "namespace" {
  default = "prisoner-content-hub-production"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Prisoner Facing Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "thehub@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}


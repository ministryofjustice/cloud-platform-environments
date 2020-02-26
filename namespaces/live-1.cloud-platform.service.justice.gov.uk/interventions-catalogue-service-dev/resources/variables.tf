variable "application" {
  default = "interventions-catalogue-service"
}

variable "namespace" {
  default = "interventions-catalogue-service-dev"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Interventions Catalogue Team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "interventions-catalogue-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}


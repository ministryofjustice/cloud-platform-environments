variable "application" {
  default = "sentence-planning"
}

variable "namespace" {
  default = "sentence-planning-development"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Sentence Planning Team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "sentence-plan-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

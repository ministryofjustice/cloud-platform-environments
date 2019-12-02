variable "application" {
  default = "Probation Core Services Tooling"
}

variable "namespace" {
  default = "probation-core-services-tooling"
}

variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-core-services"
}

variable "repo_name" {
  description = "The name of your git repo"
  default     = "digital-probation-tooling"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "tooling"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "pcs-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}


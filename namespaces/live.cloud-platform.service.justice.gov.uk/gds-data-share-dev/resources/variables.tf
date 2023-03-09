variable "application" {
  description = "Name of Application you are deploying"
  default     = "gds-data-share"
}

variable "namespace" {
  default = "gds-data-share-dev"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps-tech"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "gdx-dev-team@digital.cabinet-office.gov.uk"
}

variable "is_production" {
  default = "false"
}

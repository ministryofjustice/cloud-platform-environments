variable "vpc_name" {
}

variable "application" {
  default = "hmpps-identify-remand-periods-prod"
}

variable "namespace" {
  default = "hmpps-identify-remand-periods-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your prodelopment team"
  default     = "farsight-devs"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "rds_family" {
  default = "postgres15"
}

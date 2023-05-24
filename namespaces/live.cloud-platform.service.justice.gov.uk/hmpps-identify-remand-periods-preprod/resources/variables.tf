variable "vpc_name" {
}

variable "application" {
  default = "hmpps-identify-remand-periods-preprod"
}

variable "namespace" {
  default = "hmpps-identify-remand-periods-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your preprodelopment team"
  default     = "farsight-devs"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "rds_family" {
  default = "postgres15"
}

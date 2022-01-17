variable "domain" {
  default = "sign-in-staging.hmpps.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-auth"
}

variable "namespace" {
  default = "hmpps-auth-staging"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital Prison Services/Tech"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "rds-family" {
  default = "postgres13"
}

variable "db_instance_class" {
  default = "db.t3.small"
}

variable "db_engine_version" {
  default = "13"
}

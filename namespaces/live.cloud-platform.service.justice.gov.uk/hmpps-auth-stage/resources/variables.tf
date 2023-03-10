variable "domain" {
  default = "sign-in-stage.hmpps.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-auth"
}

variable "namespace" {
  default = "hmpps-auth-stage"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital Prison Services/Tech"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "stage"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
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

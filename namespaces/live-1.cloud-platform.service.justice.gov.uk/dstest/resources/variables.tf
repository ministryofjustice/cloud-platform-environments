variable "team_name" {
  default = "webops"
}

variable "is-production" {
  default = "true"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "MoJ Digital"
}

variable "application" {
  default = "RDS Module Test"
}

variable "environment-name" {
  default = "development"
}

variable "infrastructure-support" {
  default = "platforms@digital.justice.gov.uk"
}

variable "vpc_name" {
}

variable "application" {
  default = "HMPPS Court Probation"
}

variable "namespace" {
  default = "court-probation-e2e"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "hmpps-developers"
}

variable "environment" {
  default = "development"
}

variable "infrastructure_support" {
  default = "Probation in Court Team: probation-in-court-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}



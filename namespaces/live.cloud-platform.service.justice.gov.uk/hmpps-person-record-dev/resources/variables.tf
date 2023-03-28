variable "vpc_name" {
}

variable "application" {
  default = "HMPPS Person Record Service"
}

variable "namespace" {
  default = "hmpps-person-record-dev"
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
  default = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}



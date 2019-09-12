terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

variable "namespace" {
  default = "money-to-prisoners-test"
}

variable "business-unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "prisoner-money"
}

variable "application" {
  default = "money-to-prisoners"
}

variable "email" {
  default = "money-to-prisoners@digital.justice.gov.uk"
}

variable "environment-name" {
  default = "test"
}

variable "is-production" {
  default = "false"
}

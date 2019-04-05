terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

variable "namespace" {
  default = "cica-oas-basic-testing"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "CICA"
}

variable "application" {
  default = "cica-oas-datacapture-test"
}

variable "email" {
  default = "daniel.thornton@informed.com"
}

variable "environment-name" {
  default = "testing"
}

variable "is-production" {
  default = "false"
}

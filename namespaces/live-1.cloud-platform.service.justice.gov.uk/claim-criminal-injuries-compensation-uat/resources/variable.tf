terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

variable "namespace" {
  default = "claim-criminal-injuries-compensation-uat"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "uat"
}

variable "is-production" {
  default = "false"
}

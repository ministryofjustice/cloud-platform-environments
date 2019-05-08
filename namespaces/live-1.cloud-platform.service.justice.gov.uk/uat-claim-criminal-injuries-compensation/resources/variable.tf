variable "aws_region" {
  default = "eu-west-2"
}

terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

variable "namespace" {
  default = "uat-claim-criminal-injuries-compensation"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "uat-claim-criminal-injuries-compensation"
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


terraform {
  backend "s3" {}
}

provider "aws" {
  region = "eu-west-2"
}

variable "namespace" {
  default = "cica-oas-basic-testing"
}

variable "repo_name" {
  default = "data-capture-service"
}

variable "team_name" {
  default = "cica"
}

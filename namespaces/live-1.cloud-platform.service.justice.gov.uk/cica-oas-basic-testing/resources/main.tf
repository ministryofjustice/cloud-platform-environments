terraform {
  required_version = "0.11.14"
  backend          "s3"             {}
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
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

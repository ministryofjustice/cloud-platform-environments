# auto-generated from fb-cloud-platforms-environments
terraform {
  required_version = "0.11.14"
  backend          "s3"             {}
}

provider "aws" {
  region = "eu-west-2"
}

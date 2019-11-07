terraform {
  required_version = "0.11.14"
  backend          "s3"             {}
}

provider "aws" {
  region = "eu-west-2"
}

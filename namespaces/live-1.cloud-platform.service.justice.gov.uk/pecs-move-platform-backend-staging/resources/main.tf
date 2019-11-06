terraform {
  required_version = "0.11.14"
  backend          "s3"             {}
}

provider "aws" {
  region = "${var.aws_region}"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

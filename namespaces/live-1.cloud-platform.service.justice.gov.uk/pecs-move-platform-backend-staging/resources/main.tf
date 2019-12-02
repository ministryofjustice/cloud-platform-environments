terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}


terraform {
  backend "s3" {}
}

provider "aws" {
  alias  = "${var.aws_alias}"
  region = "${var.aws_region}"
}

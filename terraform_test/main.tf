terraform {
  backend "s3" {
    bucket = "cloud-platform-test-cluster-terraform-state"
    key    = "terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  version = "~> 1.9.0"
  region = "eu-west-1"
}

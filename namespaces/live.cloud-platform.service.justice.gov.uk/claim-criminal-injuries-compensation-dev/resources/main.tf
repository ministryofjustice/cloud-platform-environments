terraform {
  backend "s3" {
  }
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

provider "kubernetes" {
  version = "~> 1.11"
}

provider "helm" {
  kubernetes {
  }
}
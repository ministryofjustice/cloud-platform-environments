terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

# To be use in case the resources need to be created in London.
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# To be use in case the resources need to be created in Ireland.
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

# For Push gateway
provider "kubernetes" {
  version = "~> 1.11"
}

# For Push gateway
provider "helm" {
  kubernetes {
  }
}
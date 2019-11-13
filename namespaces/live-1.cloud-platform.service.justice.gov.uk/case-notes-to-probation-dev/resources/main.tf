terraform {
  required_version = "0.11.14"
  backend          "s3"             {}
}

provider "aws" {
  region = "eu-west-2"
}

# To be use in case the resources need to be created in London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

# To be use in case the resources need to be created in Ireland
provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

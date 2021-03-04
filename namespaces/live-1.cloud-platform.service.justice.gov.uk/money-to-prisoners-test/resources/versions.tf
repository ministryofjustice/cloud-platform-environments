# generated by https://github.com/ministryofjustice/money-to-prisoners-deploy
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    pingdom = {
      source = "russellcardullo/pingdom"
      version = "1.1.3"
    }
  }
}

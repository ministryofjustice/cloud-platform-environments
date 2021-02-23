
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
      # TF-UPGRADE-TODO
      #
      # No source detected for this provider. You must add a source address
      # in the following format:
      #
      # source = "your-registry.example.com/organization/pingdom"
      #
      # For more information, see the provider source documentation:
      #
      # https://www.terraform.io/docs/configuration/providers.html#provider-source
    }
  }
}

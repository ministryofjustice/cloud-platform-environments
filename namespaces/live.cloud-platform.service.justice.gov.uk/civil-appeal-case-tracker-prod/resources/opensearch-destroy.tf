terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0" # Match your original version
    }
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "2.2.1" # Match version from cloud-platform-terraform-opensearch-alert
    }
  }
}

provider "aws" {
  region = "eu-west-2" # Adjust to your AWS region (e.g., eu-west-2 for MoJ Cloud Platform)
}

provider "opensearch" {
  url = "https://cp-live-app-logs.eu-west-2.es.amazonaws.com" # Replace with your OpenSearch endpoint
}

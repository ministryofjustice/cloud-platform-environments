terraform {
  required_providers {
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "~> 2.1.0" # Match version from cloud-platform-terraform-opensearch-alert
    }
  }
}

provider "opensearch" {
  url = "https://cp-live-app-logs.eu-west-2.es.amazonaws.com" # Replace with your OpenSearch endpoint
}

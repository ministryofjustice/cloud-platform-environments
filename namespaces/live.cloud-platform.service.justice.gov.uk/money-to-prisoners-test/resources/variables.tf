variable "vpc_name" {}

variable "namespace" {
  default = "money-to-prisoners-test"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "prisoner-money"
}

variable "application" {
  default = "money-to-prisoners"
}

variable "environment-name" {
  default = "test"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "money-to-prisoners@digital.justice.gov.uk"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

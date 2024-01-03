variable "kubernetes_cluster" {}

variable "vpc_name" {}

variable "eks_cluster_name" {}

variable "application" {
  default = "HMPPS Locations Inside Prison Service"
}

variable "namespace" {
  default = "locations-inside-prison-dev"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "locations-inside-prison"
}

variable "environment" {
  default = "development"
}

variable "infrastructure_support" {
  default = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  default = "locations-inside-prison-dev"
}

variable "github_owner" {
  type    = string
  default = "ministryofjustice"
}

variable "github_token" {
  type    = string
  default = ""
}

variable "kubernetes_cluster" {}

variable "vpc_name" {}

variable "eks_cluster_name" {}

variable "application" {
  default = "HMPPS PECS Profile UI service"
}

variable "namespace" {
  default = "hmpps-pecs-profile-ui-dev"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "move-a-prisoner"
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
  default = "move-a-prisoner-digital"
}

variable "github_owner" {
  type    = string
  default = "ministryofjustice"
}

variable "github_token" {
  type    = string
  default = ""
}

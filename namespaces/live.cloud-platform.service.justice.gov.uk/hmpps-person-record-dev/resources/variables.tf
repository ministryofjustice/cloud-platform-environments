variable "vpc_name" {
}

variable "application" {
  default = "HMPPS Person Record Service"
}

variable "namespace" {
  default = "hmpps-person-record-dev"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "hmpps-person-record"
}

variable "environment" {
  default = "development"
}

variable "environment-name" {
  default = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-person-record@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}


variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

variable "eks_cluster_name" {
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hmpps-person-record-alerts"
}

variable "kubernetes_cluster" {}

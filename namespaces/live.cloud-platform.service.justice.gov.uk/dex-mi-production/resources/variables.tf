/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}


variable "namespace" {
  default = "dex-mi-production"
}


variable "is_production" {
  default = "true"
}

variable "environment" {
  default = "production"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "Central-Digital-Product-Team@digital.justice.gov.uk"
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

variable team_name {
  default = "correspondence"
}

variable business_unit {
  default = "Central Digital"
}

variable application {
  default = "dex-mi-metabase"
}


variable "kubernetes_cluster" {}

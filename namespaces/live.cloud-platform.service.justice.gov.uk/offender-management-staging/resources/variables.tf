variable "environment_name" {
  default = "staging"
}

variable "team_name" {
  default = "offender-management"
}

variable "application" {
  default = "offender-management-allocation-manager"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "is_production" {
  default = "false"
}

variable "namespace" {
  default = "offender-management-staging"
}

variable "infrastructure_support" {
  default = "manage-pom-cases@digital.justice.gov.uk"
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

/*
 * When using this module through the cloud-platform-environments, the following
 * variables are automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "kubernetes_cluster" {
  type = string
}

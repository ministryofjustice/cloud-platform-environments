/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "environment_name" {
  default = "production"
}

variable "team_name" {
  default = "offender-management"
}

variable "is_production" {
  default = "true"
}

variable "namespace" {
  default = "offender-management-production"
}

variable "infrastructure_support" {
  default = "manage-pom-cases@digital.justice.gov.uk"
}

variable "business_unit" {
  default = "HMPPS"
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


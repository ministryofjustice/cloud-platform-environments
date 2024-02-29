# auto-generated from fb-cloud-platforms-environments
variable "environment-name" {
  default = "test"
}

variable "team_name" {
  default = "formbuilder"
}

variable "namespace" {
  default = "formbuilder-publisher-test"
}

variable "is_production" {
  default = "false"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}

variable "business_unit" {
  default = "Platforms"
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


variable "kubernetes_cluster" {}

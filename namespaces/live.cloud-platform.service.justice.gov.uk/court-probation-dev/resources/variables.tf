/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "application" {
  default = "court-case-service"
}

variable "namespace" {
  default = "court-probation-dev"
}

variable "business_unit" {
  default = "HMPPS"
}

variable "team_name" {
  default = "probation-in-court-team"
}

variable "environment" {
  default = "development"
}

variable "infrastructure_support" {
  default = "Probation in Court Team: probation-in-court-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "rds-family" {
  default = "postgres11"
}

variable "db_engine_version" {
  default = "11"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "ap-stack-court-case" {
  default = "hmpps-court-case-dev"
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


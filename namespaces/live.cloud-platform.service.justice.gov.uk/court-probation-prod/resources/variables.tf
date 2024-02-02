/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "prepare-case-domain" {
  default = "prepare-case-probation.service.justice.gov.uk"
}

variable "crime-portal-mirror-gateway-domain" {
  default = "crime-portal-mirror-gateway.service.justice.gov.uk"
}

variable "application" {
  default = "court-case-service"
}

variable "namespace" {
  default = "court-probation-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-in-court"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Prepare a Case for Sentence: prepareacaseforsentence@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "rds-family" {
  default = "postgres14"
}

variable "db_engine_version" {
  default = "14.7"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "ap-stack-court-case" {
  default = "hmpps-court-case-prod"
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
variable "kubernetes_cluster" {}

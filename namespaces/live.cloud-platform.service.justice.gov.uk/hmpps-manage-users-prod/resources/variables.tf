/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "application" {
  default = "hmpps-manage-users-prod"
}

variable "application-api" {
  default = "hmpps-manage-users-api-prod"
}

variable "namespace" {
  default = "hmpps-manage-users-prod"
}

variable "domain_manage-users" {
  default = "manage-users.hmpps.service.justice.gov.uk"
}

variable "domain_manage-users-api" {
  default = "manage-users-api.hmpps.service.justice.gov.uk"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital Prison Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "node-type" {
  default = "cache.t4g.small"
}

variable "is_production" {
  default = "true"
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
  description = "The name of the eks cluster to retrieve the OIDC information"
}


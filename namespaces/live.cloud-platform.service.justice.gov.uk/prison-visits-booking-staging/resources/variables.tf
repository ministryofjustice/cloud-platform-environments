/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "environment-name" {
  default = "staging"
}

variable "team_name" {
  default = "book-a-prison-visit"
}

variable "is_production" {
  default = "false"
}

variable "namespace" {
  default = "prison-visits-booking-staging"
}

variable "infrastructure_support" {
  default = "prisonvisitsbooking@digital.justice.gov.uk"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "prison-visits-booking-staff"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
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

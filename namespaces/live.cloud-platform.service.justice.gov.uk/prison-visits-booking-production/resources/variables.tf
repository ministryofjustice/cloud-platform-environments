/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "application" {
  default = "prison-visits-booking-production"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "environment-name" {
  default = "production"
}

variable "environment" {
  default = "prod"
}

variable "service_area" {
  description = "Service area responsible for this service"
  default     = "Activities and Visits"
}

variable "team_name" {
  default = "hmpps-prison-visits-booking-live"
}

variable "is_production" {
  default = "true"
}

variable "namespace" {
  default = "prison-visits-booking-production"
}

variable "infrastructure_support" {
  default = "prisonvisitsbooking@digital.justice.gov.uk"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "visits-dev"
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

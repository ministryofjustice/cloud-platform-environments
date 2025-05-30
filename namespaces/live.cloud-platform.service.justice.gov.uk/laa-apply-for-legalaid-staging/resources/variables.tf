/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "namespace" {
  default = "laa-apply-for-legalaid-staging"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "laa-apply-for-legalaid"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "LAA"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "staging"
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
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "apply-for-civil-legal-aid@justice.gov.uk"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-apply-for-legal-aid"
}

variable "kubernetes_cluster" {}

variable "domain" {
  default = "claim-crown-court-defence.service.justice.gov.uk"
}

variable "application" {
  default = "cccd"
}

variable "namespace" {
  default = "cccd-dev-lgfs"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-get-paid"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev-lgfs"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "crowncourtdefence@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */

variable "vpc_name" {
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



variable "vpc_name" {
}


variable "application" {
  description = "Name of Application you are deploying"
  default     = "calculate-journey-variable-payments"
}

variable "namespace" {
  default = "calculate-journey-variable-payments-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "move-a-prisoner"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "environment-name" {
  description = "The environment name identifier."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "moveaprisoner@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "move-a-prisoner-digital"
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
variable "kubernetes_cluster" {}

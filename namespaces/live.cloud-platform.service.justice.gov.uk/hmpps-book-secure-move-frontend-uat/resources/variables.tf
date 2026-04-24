variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "uat"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "book-a-secure-move-frontend"
}

variable "namespace" {
  default = "hmpps-book-secure-move-frontend-uat"
}

# The following variable is provided at runtime by the pipeline.
variable "vpc_name" {
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

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "move-a-prisoner-digital"
}

variable "deployment_environment" {
  type = string
  description = "Environment code used when deploying, e.g. dev, preprod or prod"
  default = "uat"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "kubernetes_cluster" {}

variable "service_area" {
  type        = string
  description = "Service Area"
  default     = "Manage Safety"
}
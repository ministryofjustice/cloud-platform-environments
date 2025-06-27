variable "application" {
  default     = "Subject Access Request"
}

variable "namespace" {
  default     = "hmpps-subject-access-request-prod"
}

variable "business_unit" {
  default     = "HMPPS"
}

variable "team_name" {
  default     = "hmpps-sar-live"
}

variable "environment" {
  default     = "prod"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  default     = "subject-access-request-service@digital.justice.gov.uk"
}

variable "is_production" {
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "dps-subject-access-requests"
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

variable "eks_cluster_name" {}

variable "vpc_name" {}

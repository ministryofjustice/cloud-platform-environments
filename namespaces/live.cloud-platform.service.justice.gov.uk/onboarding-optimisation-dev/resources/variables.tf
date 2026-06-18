variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "onboarding-optimisation-dev"
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "onboarding-optimisation"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "HMPPS"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "justice-ai-unit"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "dev"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible for this service"
  type        = string
  default     = "ross.guilbert@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team"
  type        = string
  default     = "TBC"
}

variable "github_owner" {
  description = "The GitHub organization containing the app's code repo"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

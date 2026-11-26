variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "HMPPS CFO Case Assessment and Tracking System"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "hmpps-cfo-case-assessment-tracking-system-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "HMPPS"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "hmpps-creating-future-opportunities-devs"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "development"
}

variable "github_environment_name" {
  description = "Name of the GitHub Actions / helm-values environment this namespace serves"
  type        = string
  default     = "dev"
}

variable "require_deployment_reviewers" {
  description = "Whether deployments to this GitHub Actions environment require approval from a reviewer team"
  type        = bool
  default     = false
}

variable "deployment_reviewer_teams" {
  description = "GitHub team slugs allowed to approve deployments"
  type        = set(string)
  default     = ["hmpps-creating-future-opportunities-devs", "hmpps-creating-future-opportunities-support"]
  nullable    = false

  validation {
    condition     = length(var.deployment_reviewer_teams) >= 1 && length(var.deployment_reviewer_teams) <= 6 && alltrue([for team in var.deployment_reviewer_teams : length(trimspace(team)) > 0])
    error_message = "deployment_reviewer_teams must contain between one and six non-empty team slugs."
  }
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "cfo-ict@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "ask-about-cfo"
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
  description = "The name of the EKS cluster"
}

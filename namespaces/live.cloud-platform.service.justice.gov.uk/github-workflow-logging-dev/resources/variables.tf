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
  default     = "github-workflow-logging"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "github-workflow-logging-dev"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "Chief Engineer"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "Platforms"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "octo-developer-experience"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "live"
}

variable "environment_name" {
  description = "Environment name used by cloud-platform Terraform modules"
  type        = string
  default     = "live"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "developer-experience-team@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "devx-nudge-group"
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

variable "github_actions_repositories" {
  description = "GitHub repositories to publish Actions secrets/variables into"
  type        = list(string)
  default     = ["ministry-of-justice-github-analysis"]
}

variable "github_actions_environments" {
  description = "Optional GitHub environments in which to publish actions secrets/variables"
  type        = list(string)
  default     = []
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster (not the endpoint URL)"
  type        = string
}

variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "preprod"
}

variable "github_review_team" {
  description = "The name of the GitHub team that can review and merge PRs."
  default     = "map-developers-devs"
}

variable "github_deployment_team" {
  description = "The name of the GitHub team that can review and merge PRs."
  default     = "map-developers-live"
}

variable "service_area" {
  type        = string
  description = "Service Area"
  default     = "Manage Safety"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "move-a-prisoner-digital"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "book-a-secure-move-api"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-preprod"
}

variable "business_unit" {
  default = "Digital and Technology"
}

variable "domain" {
  default = "bookasecuremove.service.justice.gov.uk"
}

variable "backup_window" {
  default = "22:00-23:59"
}

variable "maintenance_window" {
  default = "sun:00:00-sun:03:00"
}

# The following variable is provided at runtime by the pipeline.

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
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "mp_dps_sg_name" {
  type        = string
  description = "Required for MP DPR Traffic ingress into CP DPS"
  default     = "cloudplatform-mp-dps-sg"
}

variable "kubernetes_cluster" {}

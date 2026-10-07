variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "application" {
  description = "HMPPS Prison Roll Count Service"
  default     = "hmpps-prison-roll-count"
}

variable "namespace" {
  default = "hmpps-prison-roll-count-preprod"
}

variable "business_unit" {
  default     = "HMPPS"
}

variable "team_name" {
  default     = "move-a-prisoner"
}

variable "environment" {
  default     = "preprod"
}

variable "github_review_team" {
  description = "The name of the GitHub team that can review and merge PRs."
  default     = "map-developers-devs"
}

variable "service_area" {
  type        = string
  description = "Service Area"
  default     = "Manage Safety"
}

variable "infrastructure_support" {
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  default     = "move-a-prisoner-digital"
}

variable "number_cache_clusters" {
  default = "2"
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


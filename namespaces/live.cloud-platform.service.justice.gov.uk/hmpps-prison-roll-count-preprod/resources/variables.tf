variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  default = "HMPPS Prison Roll Count Service"
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


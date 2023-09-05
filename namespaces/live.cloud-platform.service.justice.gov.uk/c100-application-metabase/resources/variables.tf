variable "team_name" {
  default = "sustainingdevs"
}

variable "environment" {
  default = "metabase"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  default = "sustainingaccountnotifications@hmcts.net"
}

variable "slack_channel" {
  default = "#hmcts-sustaining-team"
}

variable "application" {
  default = "Metabase for Apply to court about child arrangements"
}

variable "namespace" {
  default = "c100-application-metabase"
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


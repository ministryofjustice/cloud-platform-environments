/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "application" {
  default = "offender-case-notes"
}

variable "namespace" {
  default = "offender-case-notes-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "connect-dps"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "connectdps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
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

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "connect-dps"
}

variable "kubernetes_cluster" {}

variable "mp_dps_sg_name" {
  type        = string
  description = "Required for MP DPR Traffic ingress into CP DPS"
  default     = "cloudplatform-mp-dps-sg"
}
variable "service_area" {
  description = "The full name of the Service Area in which your team is based"
  default     = "Foundations"
}

variable "github_review_team" {
  description = "The name of the GitHub team that can review and merge PRs."
  default     = "connect-dps-devs"
}

variable "github_deployment_team" {
  description = "The name of the GitHub team that can deploy to this environment with GitHub Actions."
  default     = "connect-dps-live"
}

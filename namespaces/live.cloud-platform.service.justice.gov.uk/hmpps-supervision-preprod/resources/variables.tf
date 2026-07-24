variable "vpc_name" {}
variable "eks_cluster_name" {}
variable "kubernetes_cluster" {}

variable "namespace" {
  default = "hmpps-supervision-preprod"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "is_production" {
  default = "false"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "hmpps-supervision"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-integration"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-integration@JusticeUK.onmicrosoft.com"
}

variable "service_area" {
  description = "Service area responsible for this service"
  default     = "Core Supervision"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "probation-integration-team"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

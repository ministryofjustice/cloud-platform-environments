variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Integration API"
}

variable "namespace" {
  default = "hmpps-integration-api-pre-production"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-integration-api"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "pre-production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-integration-api@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "ask-hmpps-integration-api"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "base_domain" {
  default = "hmpps.service.justice.gov.uk"
}

variable "hostname" {
  description = "Host part of the FQDN"
  default     = "pre-production.integration-api"
}

variable "cloud_platform_integration_api_url" {
  description = "Pre-defined domain for the namespace provided by Cloud Platform"
  default     = "https://hmpps-integration-api-pre-production.apps.live.cloud-platform.service.justice.gov.uk"
}

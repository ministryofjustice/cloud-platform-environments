variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Integration API"
}

variable "namespace" {
  default = "hmpps-integration-api-prod"
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
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-integration-api@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hmpps-integration-api"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "github_repo_name" {
  description = "Main GitHub repository name"
  default     = "hmpps-integration-api"
}

variable "base_domain" {
  default = "hmpps.service.justice.gov.uk"
}

variable "hostname" {
  description = "Host part of the FQDN"
  default     = "integration-api"
}

variable "cloud_platform_integration_api_url" {
  description = "Pre-defined domain for the namespace provided by Cloud Platform"
  default     = "https://hmpps-integration-api-prod.apps.live.cloud-platform.service.justice.gov.uk"
}

variable "eks_cluster_name" {}

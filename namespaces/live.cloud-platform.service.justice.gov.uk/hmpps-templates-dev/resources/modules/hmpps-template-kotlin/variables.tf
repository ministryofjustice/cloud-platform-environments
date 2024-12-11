variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
}

variable "namespace" {
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
}

variable "environment" {
  description = "The type of environment you're deploying to."
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
}

variable "is_production" {
}

# application_insights_instance should be set to one of:
# "dev" (appears as t3 in azure portal) or "preprod" or "prod".
# This determines which instance of application insights metrics and logs are sent to.
variable "application_insights_instance" {
  description = "Determines which instrumentation key to use for Application Insights."
  type        = string
}

variable "number_cache_clusters" {
  default = "2"
}

variable "github_repo" {
  description = "The name of the GitHub repository where the source code for the app is stored"
}

variable "github_team" {
  description = "The name of the GitHub team that will be added as reviewers to the repository"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
}

variable "serviceaccount_name" {
  description = "The name of the service account to be created"
  default     = "github-actions-sa"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "form-builder"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}
variable "kubernetes_cluster" {
}

variable "db_backup_retention_period_hmcts_complaints_adapter" {
  default = "2"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Form Builder form-builder-team@digital.justice.gov.uk"
}

variable "namespace" {
  default = "hmcts-complaints-formbuilder-adapter-production"
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

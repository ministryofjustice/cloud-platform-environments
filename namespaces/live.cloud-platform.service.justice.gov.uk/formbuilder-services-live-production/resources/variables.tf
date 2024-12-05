variable "is_production" {
  default = "true"
}

variable "environment-name" {
  default = "live-production"
}

variable "team_name" {
  default = "formbuilder"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-team@digital.justice.gov.uk"
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
}
variable "kubernetes_cluster" {
}

variable "namespace" {
  default = "formbuilder-services-live-production"
}

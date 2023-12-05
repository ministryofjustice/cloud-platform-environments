variable "environment_name" {
  default = "test"
}

variable "team_name" {
  default = "formbuilder"
}

variable "is_production" {
  default = "true"
}

variable "db_backup_retention_period" {
  default = "2"
}

variable "infrastructure_support" {
  default = "Form Builder form-builder-developers@digital.justice.gov.uk"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}


variable "namespace" {
  default = "formbuilder-saas-test"
}

variable "db_instance_class" {
  default = "db.t4g.large"
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

variable "eks_cluster_name" {}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

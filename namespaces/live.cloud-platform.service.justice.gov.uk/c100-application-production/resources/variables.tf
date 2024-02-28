variable "team_name" {
  default = "sustainingdevs"
}

variable "business_unit" {
  default = "HMCTS"
}

variable "environment-name" {
  default = "production"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  default = "sustainingaccountnotifications@hmcts.net"
}

variable "application" {
  default = "Apply to court about child arrangements"
}

variable "namespace" {
  default = "c100-application-production"
}

# Database

variable "db_engine_version" {
  default = "14.10"
}

variable "db_instance_class" {
  default = "db.t4g.small"
}

variable "db_engine_family" {
  default = "postgres14"
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

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
}

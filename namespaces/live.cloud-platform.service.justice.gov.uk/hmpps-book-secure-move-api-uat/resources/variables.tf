variable "team_name" {
  default = "book-a-secure-move"
}

variable "environment-name" {
  default = "uat"
}

variable "is_production" {
  default = "false"
}

variable "infrastructure_support" {
  default = "pecs-digital-tech@digital.justice.gov.uk"
}

variable "application" {
  default = "book-a-secure-move-api"
}

variable "namespace" {
  default = "hmpps-book-secure-move-api-uat"
}

variable "business_unit" {
  default = "Digital and Technology"
}

variable "domain" {
  default = "bookasecuremove.service.justice.gov.uk"
}

variable "backup_window" {
  default = "22:00-23:59"
}

variable "maintenance_window" {
  default = "sun:00:00-sun:03:00"
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
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "kubernetes_cluster" {}

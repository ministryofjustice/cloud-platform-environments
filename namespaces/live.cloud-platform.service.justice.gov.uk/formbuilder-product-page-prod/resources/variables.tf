variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "application" {
  default = "MOJ Forms Product Page"
}

variable "namespace" {
  default = "formbuilder-product-page-prod"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "formbuilder"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "zone_name_new" {
  default = "moj-forms.service.justice.gov.uk"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "form-builder-developers@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
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


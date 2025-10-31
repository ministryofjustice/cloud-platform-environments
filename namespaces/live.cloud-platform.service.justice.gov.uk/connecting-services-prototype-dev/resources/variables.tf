variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "application" {
  description = "Name of Application you are deploying"
  type        = string
  default     = "Connecting Services Prototype"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "connecting-services-prototype-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  type        = string
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  type        = string
  default     = "central-digital-product-team"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  type        = string
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  type        = string
  default     = "central-digital-product-team@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  type        = string
  default     = "connecting-services-prototype"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  type        = string
  default     = ""
}

variable "oidc_name" {
  description = "Name of the OIDC provider (github or circleci)"
  type        = string
  default     = "github"
}

variable "app_repo" {
  description = "Name of application repository"
  type        = string
  default     = "connecting-services-prototype"
}

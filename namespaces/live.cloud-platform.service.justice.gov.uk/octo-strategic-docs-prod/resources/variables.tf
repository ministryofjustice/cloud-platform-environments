variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  type        = string
  default     = "OCTO Strategic Documentation"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "octo-strategic-docs-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  type        = string
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  type        = string
  default     = "octo-data-architecture"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  type        = string
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  type        = string
  default     = "DataArchitectureJustice@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  type        = string
  default     = "octo-data-architecture"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider."
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  type        = string
  default     = ""
}

variable "app_repo" {
  description = "Name of application repository"
  type        = string
  default     = "octo-strategic-docs"
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  type        = string
  default     = "KUBE_CLUSTER"
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  type        = string
  default     = "KUBE_NAMESPACE"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  type        = string
  default     = "KUBE_CERT"
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  type        = string
  default     = "KUBE_TOKEN"
}

variable "github_actions_secret_ecr_name" {
  description = "The name of the github actions secret containing the ECR name"
  type        = string
  default     = "ECR_NAME"
}

variable "github_actions_secret_ecr_url" {
  description = "The name of the github actions secret containing the ECR URL"
  type        = string
  default     = "ECR_URL"
}

variable "github_actions_secret_ecr_access_key" {
  description = "The name of the github actions secret containing the ECR AWS access key"
  type        = string
  default     = "ECR_AWS_ACCESS_KEY_ID"
}

variable "github_actions_secret_ecr_secret_key" {
  description = "The name of the github actions secret containing the ECR AWS secret key"
  type        = string
  default     = "ECR_AWS_SECRET_ACCESS_KEY"
}

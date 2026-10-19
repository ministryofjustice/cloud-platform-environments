variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "CICA Digital and Data Docs"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "cica-docs-prod"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "CICA Digital"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "CICA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "cica-digital-and-data"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "production"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "cica.digital@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "cica-digital-unit"
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


variable "app_repo" {
  description = "Name of the application's GitHub repository"
  type        = string
  default     = "cica-digital-and-data"
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

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
  type        = string
}
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
  default     = "Apply for criminal legal aid"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-apply-for-criminal-legal-aid-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "laa-crime-apply"
}

variable "repo_name" {
  default = "laa-apply-for-criminal-legal-aid"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "laacrimeapply@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-crime-apply"
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

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_PREPROD_NAMESPACE"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_PREPROD_CERT"
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_PREPROD_TOKEN"
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the serviceaccount cluster"
  default     = "KUBE_PREPROD_CLUSTER"
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
}

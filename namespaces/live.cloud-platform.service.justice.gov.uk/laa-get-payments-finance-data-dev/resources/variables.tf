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
  default     = "Get payments and finance data"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-get-payments-finance-data-dev"
}

variable "testing_ecr" {
  description = "ECR Name of the namespace these resources are part of"
  type        = string
  default     = "laa-get-payments-finance-data-dev-testing"
}

variable "data_ecr" {
  description = "ECR Name of the namespace these resources are part of"
  type        = string
  default     = "laa-get-payments-finance-data-dev-data"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "payforlegalaid"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "development"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "laa-payments-finance@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-get-payments-finance-data"
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

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  default     = "KUBE_CLUSTER_DEV"
  type        = string
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_NAMESPACE_DEV"
  type        = string
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_CERT_DEV"
  type        = string
  sensitive   = true
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_TOKEN_DEV"
  type        = string
  sensitive   = true
}

variable "file_store_bucket_name" {
  description = "The name of the S3 bucket used for storing templates"
  default     = "laa-get-payments-finance-data-dev-file-store"
  type        = string
}

variable "report_store_bucket_name" {
  description = "The name of the S3 bucket used for storing complete reports"
  default     = "laa-get-payments-finance-data-dev-report-store"
  type        = string
}

variable "s3_bucket_report_store_logging" {
  description = "The name of the S3 bucket used for logging the report store bucket"
  default     = "laa-get-payments-finance-data-dev-report-store-logging"
  type        = string
}


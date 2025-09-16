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
  default     = "Claims events service"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-data-claims-event-service-staging"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "laa-data-stewardship-payments-team"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "staging"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "laa-dstew-payments@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-data-stewardship-payments"
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
  description = "The name of the cluster (eg.: cloud-platform-live-0)"
  type        = string
  default     = "example_name"
}

variable "cd_serviceaccount_name" {
  type        = string
  description = "Name of the service account used by GitHub Actions to deploy the applications to cloud-platform"
  default     = "claims-event-service-staging-cd-serviceaccount"
}

variable "irsa_serviceaccount_name" {
  type        = string
  description = "Name of the service account used by GitHub Actions to deploy the applications to cloud-platform"
  default     = "claims-event-service-staging-irsa-serviceaccount"
}

variable "producer_namespace" {
  type        = string
  description = "The namespace of the SQS producer"
  default     = "laa-data-claims-api-staging"
}

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
  default     = "Accredited Programmes Manage And Deliver"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "hmpps-manage-and-deliver-accredited-programmes-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "Platforms"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "hmpps-accredited-programmes-manage-and-deliver-devs"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "prod"
}

variable "environment-name" {
  default = "prod"
}


variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "interventions-devs@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "hmpps_accredited_programmes_manage_and_deliver"
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

variable "number_cache_clusters" {
  default = "2"
}

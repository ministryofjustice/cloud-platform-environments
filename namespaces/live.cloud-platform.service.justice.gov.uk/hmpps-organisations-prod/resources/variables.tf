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
  default     = "HMPPS Organisations"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "hmpps-organisations-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "HMPPS"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "hmpps-move-and-improve"
}

####################################################################################################################
### Change this environment to the environment name corresponding to this namespace (as per helm/values-ENV.dev) ###
variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "prod"
}
####################################################################################################################


variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "public_move-and-improve"
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

variable "number_cache_clusters" {
  default = "2"
}

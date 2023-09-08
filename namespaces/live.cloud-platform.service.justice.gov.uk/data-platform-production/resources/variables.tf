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
  default     = "Data Platform"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "data-platform-production"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "Platforms"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "data-platform-core-infra"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "production"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "data-platform-tech@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "data-platform-tech"
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

variable "dns_zone_id" {
  description = "Hosted Zone Id for alpha cluster loadbalancer, required for allowing traffic to be temporarily routed to old cluster for apps"
  type        = string
  default     = "Z2IFOLAFXWLO4F"
}

variable "nlb_dns_name" {
  description = "DNS name for the alpha cluster loadbalancer, required to temporarily route some traffic to the legacy cluster."
  type        = string
  default     = "ac024c043c67711e884e302093cf25df-c199fcff8de8a5ae.elb.eu-west-1.amazonaws.com"
}
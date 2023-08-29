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
  default     = "cica-apply-service"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "claim-criminal-injuries-compensation-stag"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "CICA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "cica"
}

variable "environment-name" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "staging"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "infrastructure@cica.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "cica-digital"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "CriminalInjuriesCompensationAuthority"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

variable "db_backup_retention_period" {
  description = "The days to retain backups. Must be 1 or greater to be a source for a Read Replica"
  default     = "35"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "service_monitor" {
  description = "If true, prometheus will automatically scrape"
  default     = true
}

variable "eks_cluster_name" {
}
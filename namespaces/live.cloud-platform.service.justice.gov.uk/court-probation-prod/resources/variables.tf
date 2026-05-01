/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "prepare-case-domain" {
  default = "prepare-case-probation.service.justice.gov.uk"
}

variable "crime-portal-mirror-gateway-domain" {
  default = "crime-portal-mirror-gateway.service.justice.gov.uk"
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "court-case-service"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "court-probation-prod"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "Probation In Court"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  type        = string
  default     = "HMPPS"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "probation-in-court"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "prod"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "Prepare a Case for Sentence: prepareacaseforsentence-gg@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "rds-family" {
  default = "postgres14"
}

variable "db_engine_version" {
  default = "14.17"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "ap-stack-court-case" {
  default = "hmpps-court-case-prod"
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
}

variable "slack_channel" {
  type        = string
  description = "Cloud Platform will contact our team via this slack channel"
  default     = "pic-mafia"
}

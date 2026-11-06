variable "vpc_name" {
  description = "VPC name used by the Cloud Platform RDS module"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name used by the serviceaccount module"
  type        = string
}

variable "eks_cluster_name" {
  description = "EKS cluster name used by the Cloud Platform IRSA module"
  type        = string
}

variable "application" {
  description = "Name of the application deployed in this namespace"
  type        = string
  default     = "PPUD Replacement"
}

variable "namespace" {
  description = "Namespace these resources belong to"
  type        = string
  default     = "jaiu-ppud-dev"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "STG"
}

variable "business_unit" {
  description = "Ministry of Justice business unit responsible for this service"
  type        = string
  default     = "HQ"
}

variable "team_name" {
  description = "Development team responsible for this service"
  type        = string
  default     = "justice-ai-unit"
}

variable "environment" {
  description = "Environment name used in resource tags"
  type        = string
  default     = "development"
}

variable "infrastructure_support" {
  description = "Support contact for this service"
  type        = string
  default     = "ai@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this namespace is production"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel for this team"
  type        = string
  default     = "platform-eng-ai-unit"
}

variable "github_owner" {
  description = "GitHub organization that owns the application repository"
  type        = string
  default     = "JusticeAIUnit"
}

variable "github_token" {
  description = "GitHub provider token, supplied by the approved Terraform environment if needed"
  type        = string
  sensitive   = true
  default     = ""
}

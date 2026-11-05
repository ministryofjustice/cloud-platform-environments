variable "vpc_name" {
  description = "Cloud Platform VPC name used by the RDS module"
  type        = string
}

variable "eks_cluster_name" {
  description = "Cloud Platform EKS cluster name used by the IRSA module"
  type        = string
}


variable "kubernetes_cluster" {
  description = "Existing Cloud Platform live cluster name used by namespace service-account resources"
  type        = string
}

variable "namespace" {
  description = "Namespace managed by this Terraform root"
  type        = string
  default     = "jaiu-ppud-prod"
}

variable "application" {
  description = "Application name"
  type        = string
  default     = "PPUD Replacement"
}

variable "business_unit" {
  description = "MoJ business unit"
  type        = string
  default     = "HQ"
}

variable "team_name" {
  description = "Owning team"
  type        = string
  default     = "justice-ai-unit"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "production"
}

variable "infrastructure_support" {
  description = "Team support contact"
  type        = string
  default     = "ai@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this is a production environment"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Owning team Slack channel"
  type        = string
  default     = "platform-eng-ai-unit"
}

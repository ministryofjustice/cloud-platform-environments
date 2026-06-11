variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster to retrieve OIDC information for IRSA"
  type        = string
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "Corporate Information System v2.0"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "cis-pp"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "Hosting"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "v1-cis-mod"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "preproduction"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "liam.rundle@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "cis-cloud-platform"
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

variable "github_repository" {
  description = "GitHub repository name for frontend CI/CD deploy credentials"
  type        = string
  default     = "cis-modernisation"
}

variable "github_environment" {
  description = "GitHub environment name for deploy secrets"
  type        = string
  default     = "preproduction"
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  type        = string
  default     = "KUBE_CLUSTER"
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  type        = string
  default     = "KUBE_NAMESPACE"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  type        = string
  default     = "KUBE_CERT"
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  type        = string
  default     = "KUBE_TOKEN"
}

# =============================================================================
# Frontend Module Variables
# =============================================================================

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  type        = string
  default     = "moj-laa-cis-pp-frontend"
}

variable "waf_allowed_ips" {
  description = "List of allowed IP addresses in CIDR notation for WAF IP set. Leave empty for public access with managed WAF rules only."
  type        = list(string)
  default = [
    "35.176.93.186/32",
    "18.169.147.172/32",
    "18.130.148.126/32", # Gateway IP for Global Protect alpha VPN firewall
    "35.176.148.126/32",
    "128.77.75.64/26",   # Prisma egress
    "51.149.249.0/29",   # MOJ public egress
    "194.33.249.0/29",
    "51.149.249.32/29",
    "194.33.248.0/29",
    "128.77.75.128/26",
    "128.77.75.0/26",
  ]
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
}

variable "acm_certificate_arn" {
  description = "ARN of ACM certificate for custom domain (leave empty for CloudFront default) - DEPRECATED: use use_custom_certificate instead"
  type        = string
  default     = ""
}

variable "use_custom_certificate" {
  description = "Enable ACM certificate and custom domain for CloudFront"
  type        = bool
  default     = true
}

variable "cloudfront_alias" {
  description = "Primary custom domain for the CloudFront distribution"
  type        = string
  default     = "cis-pp.service.justice.gov.uk"
}

variable "geo_restriction_type" {
  description = "Type of geo restriction (none, whitelist, blacklist)"
  type        = string
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "List of country codes for geo restriction"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# CloudFront Logging Variables
# -----------------------------------------------------------------------------
variable "cloudfront_log_retention_days" {
  description = "Number of days to retain CloudFront access logs"
  type        = number
  default     = 30
}

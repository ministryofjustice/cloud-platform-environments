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

# =============================================================================
# Frontend Module Variables
# =============================================================================

variable "environment" {
  description = "Environment name (e.g., cis-pp, cis-prod)"
  type        = string
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for frontend hosting"
  type        = string
}

variable "waf_allowed_ips" {
  description = "List of allowed IP addresses in CIDR notation for WAF IP set"
  type        = list(string)
  default     = []
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
  description = "Enable custom certificate lookup for CloudFront (looks up cert by Name tag: {environment}-frontend-certificate)"
  type        = bool
  default     = false
}

variable "cloudfront_aliases" {
  description = "List of custom domain aliases for CloudFront distribution"
  type        = list(string)
  default     = []
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
# Common Tag Variables
# -----------------------------------------------------------------------------
variable "application_tag" {
  description = "Application name tag"
  type        = string
}

variable "project_tag" {
  description = "Project name tag"
  type        = string
}

variable "version_tag" {
  description = "Version tag"
  type        = string
}

variable "technical_owner_tag" {
  description = "Technical owner tag"
  type        = string
}

variable "business_owner_tag" {
  description = "Business owner tag"
  type        = string
}

# -----------------------------------------------------------------------------
# CloudFront Logging Variables
# -----------------------------------------------------------------------------
variable "cloudfront_log_retention_days" {
  description = "Number of days to retain CloudFront access logs"
  type        = number
  default     = 30
}
variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "intranet"
}

variable "namespace" {
  default = "intranet-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "central-digital-product-team"
}

variable "is_production" {
  default = "false"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "central-digital-product-team@digital.justice.gov.uk"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "central-digital-product-team"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  default     = "KUBE_CLUSTER"
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_NAMESPACE"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_CERT"
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_TOKEN"
}

variable "cloudfront_alias" {
  description = "Aliases for the CloudFront distribution"
  type        = string
  default     = "cdn.dev-intranet.apps.live.cloud-platform.service.justice.gov.uk"
}

variable "public_key_pems" {
  description = "Public key pems to be used for CloudFront"
  type        = list(string)
  default     = [
<<EOT
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxWg0l5/+AKzmnvtLusj5
l5onx+tGZl6fRHbE6CXlqQbmQ3bpr6WakfOT3nedqTYbox/46kn6DtCpJXg/53aN
3SnkfR7rhNRYjIv5Ye6Oo0BsIvgW/i8uleSIiI8T0XNy8BOZRKxVXahG05/WgNYX
ygMcck4uQsy0QSP7kJJWwGgbDIKqCwTwJlTJHGlG2T4myOSqjvM3xGVbXwX9XLmL
e/EayVZ15QK3Ig+wpO/REtkfZ6faMHBaPibd7vutvErtFJA2BPsa71v54xfP6vbd
Gn5Z2zuqIKRIRsjbgwgnqrdCxhGHecB3g3MdcaGzb2zkI76IHgAzvQDjt/aecrDy
SQIDAQAB
-----END PUBLIC KEY-----
EOT
  ]
}

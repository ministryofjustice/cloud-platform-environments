
variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "team_name" {
  default = "family-justice"
}

variable "business_unit" {
  default = "HQ"
}

variable "environment_name" {
  default = "production"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  default = "central-digital-product-team@digital.justice.gov.uk"
}

variable "application" {
  default = "Check when to disclose cautions or convictions"
}

variable "namespace" {
  default = "disclosure-checker-production"
}

variable "repo_name" {
  default = "disclosure-checker"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

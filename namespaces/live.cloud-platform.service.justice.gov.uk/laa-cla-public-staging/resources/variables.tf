variable "namespace" {
  default = "laa-cla-public-staging"
}

variable "business_unit" {
  default = "LAA"
}

variable "team_name" {
  default = "laa-get-access"
}

variable "application" {
  default = "Civil Legal Advice Public"
}

variable "repo_name" {
  default = "cla_public"
}

variable "email" {
  default = "civil-legal-advice@digital.justice.gov.uk"
}

variable "environment-name" {
  default = "staging"
}

variable "is_production" {
  default = "false"
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


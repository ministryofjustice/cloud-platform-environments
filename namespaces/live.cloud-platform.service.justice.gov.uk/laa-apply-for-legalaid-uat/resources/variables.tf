variable "namespace" {
  default = "laa-apply-for-legalaid-uat"
}

variable "repo_name" {
  description = "The name of github repo"
  default     = "laa-apply-for-legal-aid"
}

# no longer used but presence still required
variable "kubernetes_cluster" {
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

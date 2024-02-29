variable "domain" {
  default = "laa-fee-calculator.service.justice.gov.uk"
}

variable "application" {
  default = "LAA Fee Calculator"
}

variable "namespace" {
  default = "laa-fee-calculator-staging"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-get-paid"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "LAA get paid team: laa-get-paid@digital.justice.gov.uk"
}

variable "repo_name" {
  default = "laa-fee-calculator"
}

variable "is_production" {
  default = "false"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
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


variable "kubernetes_cluster" {}

variable "namespace" {
  default = "laa-fala-production"
}

variable "business-unit" {
  default = "LAA"
}

variable "team_name" {
  default = "laa-get-access"
}

variable "application" {
  default = "Find A Legal Advisor"
}

variable "repo_name" {
  default = "fala"
}

variable "email" {
  default = "civil-legal-advice@digital.justice.gov.uk"
}

variable "environment-name" {
  default = "production"
}

variable "is-production" {
  default = "true"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "civil-legal-advice@digital.justice.gov.uk"
}


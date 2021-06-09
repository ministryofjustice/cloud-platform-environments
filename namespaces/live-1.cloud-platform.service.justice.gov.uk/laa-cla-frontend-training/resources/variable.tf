variable "namespace" {
  default = "laa-cla-frontend-training"
}

variable "business-unit" {
  default = "LAA"
}

variable "team_name" {
  default = "laa-get-access"
}

variable "application" {
  default = "Civil Legal Advice Case Handling System"
}

variable "repo_name" {
  default = "cla_frontend"
}

variable "email" {
  default = "civil-legal-advice@digital.justice.gov.uk"
}

variable "environment-name" {
  default = "training"
}

variable "is-production" {
  default = "true"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "civil-legal-advice@digital.justice.gov.uk"
}
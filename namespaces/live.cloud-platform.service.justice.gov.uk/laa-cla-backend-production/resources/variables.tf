variable "namespace" {
  default = "laa-cla-backend-production"
}

variable "business_unit" {
  default = "LAA"
}

variable "team_name" {
  default = "laa-get-access"
}

variable "application" {
  default = "Backend API for the Civil Legal Aid applications"
}

variable "environment-name" {
  default = "production"
}

variable "is_production" {
  default = "true"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "civil-legal-advice@digital.justice.gov.uk"
}

variable "vpc_name" {
}

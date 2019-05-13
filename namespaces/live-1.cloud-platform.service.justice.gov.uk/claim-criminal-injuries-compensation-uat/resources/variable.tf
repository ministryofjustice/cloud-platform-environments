variable "namespace" {
  default = "claim-criminal-injuries-compensation"
}

variable "business-unit" {
  default = "cica"
}

variable "team_name" {
  default = "cica-dev-team"
}

variable "application" {
  default = "claim-criminal-injuries-compensation"
}

variable "email" {
  default = "Infrastructure@cica.gov.uk"
}

variable "environment-name" {
  default = "uat"
}

variable "is-production" {
  default = "false"
}

variable "domain" {
  default = "uat-claim-criminal-injuries-compensation.service.justice.gov.uk"
}

variable "namespace" {
  default = "claim-criminal-injuries-compensation-uat"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "Infrastructure@cica.gov.uk"
}

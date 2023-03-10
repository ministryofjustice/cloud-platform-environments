variable "namespace" {
  default = "hmpps-audit-prod"
}


variable "vpc_name" {
}

variable "domain_audit_api" {
  default = "audit-api.hmpps.service.justice.gov.uk"
}


variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "application" {
  description = "The name of the application"
  default     = "HMPPS-Audit-Service"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital-Prison-Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}


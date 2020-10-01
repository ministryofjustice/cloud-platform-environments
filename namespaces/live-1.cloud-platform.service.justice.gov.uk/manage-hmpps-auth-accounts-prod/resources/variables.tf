variable "domain" {
  default = "manage-hmpps-auth-accounts.prison.service.justice.gov.uk"
}

variable "application" {
  default = "manage-hmpps-auth-accounts-prod"
}

variable "namespace" {
  default = "manage-hmpps-auth-accounts-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital Prison Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "node-type" {
  default = "cache.t2.small"
}

variable "is-production" {
  default = "true"
}

variable "is_production" {
  default = "true"
}

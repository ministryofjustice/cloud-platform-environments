variable "application" {
  default = "token-verification"
}

variable "namespace" {
  default = "token-verification-api-prod"
}


variable "vpc_name" {
}


variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your prodelopment team"
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

variable "number_cache_clusters" {
  default = "2"
}

variable "domain" {
  default = "token-verification-api.prison.service.justice.gov.uk"
}


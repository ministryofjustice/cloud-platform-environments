variable "application" {
  default = "court-case-service"
}

variable "namespace" {
  default = "court-probation-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-in-court-team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-in-court-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "ap-stack-court-case" {
  default = "hmpps-court-case-preprod"
}

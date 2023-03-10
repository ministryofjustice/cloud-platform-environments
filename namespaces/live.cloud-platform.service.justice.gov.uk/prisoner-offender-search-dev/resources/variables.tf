variable "domain" {
  default = "prisoner-offender-search-dev.prison.service.justice.gov.uk"
}

variable "application" {
  default = "prisoner-offender-search"
}

variable "namespace" {
  default = "prisoner-offender-search-dev"
}


variable "vpc_name" {
}


variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "eks_cluster_name" {
}

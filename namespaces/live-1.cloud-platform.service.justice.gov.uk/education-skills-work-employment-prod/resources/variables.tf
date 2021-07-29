variable "application" {
  default = "education-skills-work-employment"
}

variable "namespace" {
  default = "education-skills-work-employment-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "cluster_name" {
}

variable "node-type" {
  default = "cache.t2.small"
}


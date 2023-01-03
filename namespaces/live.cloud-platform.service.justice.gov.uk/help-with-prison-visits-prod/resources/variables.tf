variable "application" {
  default = "help-with-prison-visits"
}

variable "namespace" {
  default = "help-with-prison-visits-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Help With Prison Visits"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "prisonvisitsbooking@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}


variable "vpc_name" {
}

variable "number_cache_clusters" {
  description = "The number of cache clusters (primary and replicas) this replication group will have. Default is 2"
  type        = string
  default     = "2"
}

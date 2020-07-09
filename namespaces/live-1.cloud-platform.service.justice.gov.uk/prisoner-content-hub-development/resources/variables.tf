variable "domain" {
  default = "content-hub.prisoner.service.justice.gov.uk/ "
}

variable "application" {
  default = "prisoner-content-hub"
}

variable "namespace" {
  default = "prisoner-content-hub-development"
}

# this is injected by Cloud Platform automatically so we do not need to populate it here
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

# We chose pfs because this variable is used to create domain names for resources
# e.g. ElasticSearch. When concatenated with the environment name and unique name,
# this only leaves a handful of characters for the team_name.
variable "team_name" {
  description = "DNS compliant name of the development team"
  default     = "pfs"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "thehub@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}


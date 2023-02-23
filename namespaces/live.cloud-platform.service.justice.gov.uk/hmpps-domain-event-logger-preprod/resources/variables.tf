
variable "cluster_name" {
}

variable "vpc_name" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Domain Event Logger"
}

variable "namespace" {
  default = "hmpps-domain-event-logger-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "syscon-devs"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "syscon_team"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "node-type" {
  default = "cache.t2.small"
}


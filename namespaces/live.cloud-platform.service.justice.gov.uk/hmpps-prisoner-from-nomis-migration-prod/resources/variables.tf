
variable "cluster_name" {
}

variable "domain" {
  default = "prisoner-nomis-migration.hmpps.service.justice.gov.uk"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Prisoner from NOMIS Migration"
}

variable "namespace" {
  default = "hmpps-prisoner-from-nomis-migration-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "dps-syscon"
}

variable "environment" {
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

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "syscon_team"
}


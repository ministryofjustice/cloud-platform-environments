
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS EMS Platform"
}

variable "domain" {
  default = "electronic-monitoring.service.justice.gov.uk"
}

variable "namespace" {
  default = "hmpps-ems-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-ems-team"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-ems-platform-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hmpps-ems-platform-team"
}

# DEPRECATED: snake-case variables are the default. The definitions below
# have been left in place until all code has been updated to use snake-case
# variable names.

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "hmpps-ems-team"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-ems-platform-team@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hmpps-ems-platform-team"
}


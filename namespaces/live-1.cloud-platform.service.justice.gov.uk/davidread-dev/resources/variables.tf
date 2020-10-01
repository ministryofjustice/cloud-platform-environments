
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "App for personal test purposes"
}

variable "namespace" {
  default = "davidread-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "cloud-platform-test"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "david.read@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "davidread"
}

# DEPRECATED: snake-case variables are the default. The definitions below
# have been left in place until all code has been updated to use snake-case
# variable names.

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HQ"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "cloud-platform-test"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "david.read@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "davidread"
}


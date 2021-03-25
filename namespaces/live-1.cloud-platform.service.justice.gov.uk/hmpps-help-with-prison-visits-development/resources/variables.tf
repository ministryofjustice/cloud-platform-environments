
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Help with Prison Visits"
}

variable "namespace" {
  default = "hmpps-help-with-prison-visits-development"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-help-with-prison-visits"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "prisonvisitsbooking@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "prison-visit-booking"
}

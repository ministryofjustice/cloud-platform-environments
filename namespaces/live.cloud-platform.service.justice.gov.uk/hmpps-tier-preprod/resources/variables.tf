variable "application" {
  default = "hmpps-tier"
}

variable "namespace" {
  default = "hmpps-tier-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Manage a Workforce Team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preproduction"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "manageaworkforce@justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

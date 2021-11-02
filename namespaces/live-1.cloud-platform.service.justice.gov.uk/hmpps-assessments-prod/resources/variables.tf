
variable "cluster_name" {
}


variable "application" {
  description = "Name of Application you are deploying"
  default     = "Assess risks and needs"
}

variable "namespace" {
  default = "hmpps-assessments-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-assessments"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "assess-risks-and-needs@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hmpps-assessments-dev"
}

variable "rds_family" {
  default = "postgres10"
}

variable "domain" {
  default = "hmpps-assessments.service.justice.gov.uk"
}

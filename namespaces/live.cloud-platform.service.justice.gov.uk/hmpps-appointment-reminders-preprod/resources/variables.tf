variable "kubernetes_cluster" {
}


variable "vpc_name" {
}


variable "application" {
  default = "hmpps-appointment-reminders"
}

variable "namespace" {
  default = "hmpps-appointment-reminders-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-integration"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-integration-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}

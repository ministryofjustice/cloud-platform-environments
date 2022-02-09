variable "kubernetes_cluster" {
}

variable "cluster_name" {
}


variable "application" {
  default = "hmpps-tier-to-delius-update"
}

variable "namespace" {
  default = "hmpps-tier-to-delius-update-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "manage-a-workforce"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preproduction"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "manage_a_workforce_dev"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}


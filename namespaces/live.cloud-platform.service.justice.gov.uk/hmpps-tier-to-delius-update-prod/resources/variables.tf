variable "kubernetes_cluster" {
}

variable "cluster_name" {
}

variable "vpc_name" {
}

variable "application" {
  default = "hmpps-tier-to-delius-update"
}

variable "namespace" {
  default = "hmpps-tier-to-delius-update-prod"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Manage a Workforce Team"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}

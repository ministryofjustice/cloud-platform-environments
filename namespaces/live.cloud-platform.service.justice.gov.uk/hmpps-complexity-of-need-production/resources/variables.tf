variable "namespace" {
  default = "hmpps-complexity-of-need-production"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "offender-management"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "manage-pom-cases@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "manage-pom-cases"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}

variable "application" {
  type    = string
  default = "hmpps-complexity-of-need"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * variables are automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
  type = string
}

variable "eks_cluster_name" {
  type = string
}

variable "kubernetes_cluster" {
  type = string
}

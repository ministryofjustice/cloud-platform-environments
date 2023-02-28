variable "kubernetes_cluster" {
}


variable "vpc_name" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "WMT"
}

variable "namespace" {
  default = "hmpps-workload-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "manage-a-workforce"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "preproduction"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "manageaworkforce@justice.gov.uk"
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

variable "number_cache_clusters" {
  default = "2"
}
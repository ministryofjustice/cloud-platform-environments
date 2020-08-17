
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "David Test"
}

variable "namespace" {
  default = "david-test"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "WebOps"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "david.salgado@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "cloud-platform"
}

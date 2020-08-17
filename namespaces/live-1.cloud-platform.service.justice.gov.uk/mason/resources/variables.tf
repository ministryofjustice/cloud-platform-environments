
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "mason"
}

variable "namespace" {
  default = "mason"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "mason"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "mason"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "mason"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "mason@mason"
}

variable "is-production" {
  default = "true"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "mason"
}

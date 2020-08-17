
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "jason"
}

variable "namespace" {
  default = "jason"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "jason"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "jason"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "jason"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "jason@jason"
}

variable "is-production" {
  default = "false"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "jason"
}

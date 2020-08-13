
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Hello World"
}

variable "namespace" {
  default = "anasir_test_hello_world"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "check-my-diary"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "developemnt"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "aisha.nasir@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "cmd-dev"
}

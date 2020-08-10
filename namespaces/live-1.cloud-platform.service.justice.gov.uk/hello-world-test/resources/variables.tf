
variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Hello World Cloud Platform Test"
}

variable "namespace" {
  default = "hello-world-test"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS Digital"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "Sentencing and Oasys Development"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "natalie.wood@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "slack-channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "hello-world-test"
}


variable "cluster_name" {
}

variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Test Nginx Ingress"
}

variable "namespace" {
  default = "mogaal-test"
}

variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "cloud-platform"
}

variable "team-name" {
  description = "The name of your development team"
  default     = "webops"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platform@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "domain" {
  description = "Domain to be created"
  default     = "mogaal-test.cloud-platform.service.justice.gov.uk"
}

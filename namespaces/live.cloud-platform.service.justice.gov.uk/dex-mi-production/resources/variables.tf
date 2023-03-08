/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 */


variable "vpc_name" {
}


variable "namespace" {
  default = "dex-mi-production"
}


variable "is-production" {
  default = "true"
}

variable "environment-name" {
  default = "production"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "Central-Digital-Product-Team@digital.justice.gov.uk"
}

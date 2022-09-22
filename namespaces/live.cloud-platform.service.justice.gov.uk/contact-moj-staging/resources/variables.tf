/*
 * When using this module through the cloud-platform-environments, the following
 * two variables are automatically supplied by the pipeline.
 */

variable "cluster_name" {}

variable "vpc_name" {
}

variable "namespace" {
  default = "contact-moj-staging"
}

variable "domain" {
  default = "staging.contact-moj.service.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "environment-name" {
  default = "staging"
}

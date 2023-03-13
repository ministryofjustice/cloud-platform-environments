/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "namespace" {
  default = "laa-apply-for-legalaid-staging"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "laa-apply-for-legalaid"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "LAA"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "is_production" {
  default = "false"
}

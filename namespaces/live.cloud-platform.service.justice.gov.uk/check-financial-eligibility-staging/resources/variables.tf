variable "namespace" {
  default = "check-financial-eligibility-staging"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "check-financial-eligibility"
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

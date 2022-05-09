variable "namespace" {
  default = "laa-apply-for-legalaid-production"
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
  default     = "production"
}

variable "is_production" {
  default = "true"
}

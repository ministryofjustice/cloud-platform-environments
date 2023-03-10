variable "domain" {
  default = "laa-fee-calculator.service.justice.gov.uk"
}

variable "application" {
  default = "LAA Fee Calculator"
}

variable "namespace" {
  default = "laa-fee-calculator-production"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-get-paid"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "LAA get paid team: laa-get-paid@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

# The following variable is provided at runtime by the pipeline.

variable "vpc_name" {
}



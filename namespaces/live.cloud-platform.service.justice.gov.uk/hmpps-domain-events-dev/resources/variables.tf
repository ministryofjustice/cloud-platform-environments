variable "application" {
  default = "court-register"
}

variable "namespace" {
  default = "hmpps-domain-events-dev"
}

variable "vpc_name" {
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital-Prison-Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "false"
}

variable "github_token" {
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

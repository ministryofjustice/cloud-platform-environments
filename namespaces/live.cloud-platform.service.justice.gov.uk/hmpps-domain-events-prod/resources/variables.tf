variable "application" {
  default = "court-register"
}

variable "namespace" {
  default = "hmpps-domain-events-prod"
}

variable "cluster_name" {
}


variable "business-unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Digital-Prison-Services"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure-support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "github_token" {
  description = "Required by the GitHub Terraform provider"
  default     = ""
}


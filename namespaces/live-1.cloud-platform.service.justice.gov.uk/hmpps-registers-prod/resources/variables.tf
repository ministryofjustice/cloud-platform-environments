variable "domain_court_register" {
  default = "court-register.hmpps.service.justice.gov.uk"
}

variable "domain_prison_register" {
  default = "prison-register.hmpps.service.justice.gov.uk"
}

variable "domain_hmpps_registers" {
  default = "registers.hmpps.service.justice.gov.uk"
}

variable "court-application" {
  default = "court-register"
}

variable "prison-application" {
  default = "prison-register"
}

variable "hmpps-registers-application" {
  default = "hmpps-registers"
}

variable "namespace" {
  default = "hmpps-registers-prod"
}

variable "cluster_name" {
}

variable "cluster_state_bucket" {
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
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is-production" {
  default = "true"
}

variable "number-cache-clusters" {
  default = "2"
}

variable "domain" {
  default = "pcms-dev.prison.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-prisoner-communication-monitoring"
}

variable "namespace" {
  default = "hmpps-pin-phone-monitor-dev"
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
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "number_cache_clusters" {
  default = "2"
}

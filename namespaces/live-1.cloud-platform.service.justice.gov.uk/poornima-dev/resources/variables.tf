variable "domain" {
  default = "dev-pk.service.justice.gov.uk"
}

variable "namespace" {
  default = "poornima-dev"
}

variable "application" {
  default = "test-app-poornima-dev"
}

variable "business-unit" {
  description = "MOJ Digital"
  default     = "mojdigital"
}

variable "team_name" {
  default     = "cloud-platform"
  description = "Cloud Platform"
}

variable "environment-name" {
  default     = "test"
  description = "Development/Test environment"
}

variable "infrastructure-support" {
  default     = "poornima.krishnasamy@digital.justice.gov.uk"
  description = "Cloud Platform"
}

variable "is-production" {
  default = "false"
}

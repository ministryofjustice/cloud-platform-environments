
variable "cluster_name" {
}


variable "domain" {
  default = "dev-pk.service.justice.gov.uk"
}

variable "namespace" {
  default = "poornima-staging"
}

variable "application" {
  default = "test-app-poornima-staging"
}

variable "business_unit" {
  description = "MOJ Digital"
  default     = "mojdigital"
}

variable "team_name" {
  default     = "cloud-platform"
  description = "Cloud Platform"
}

variable "environment_name" {
  default     = "test"
  description = "Development/Test environment"
}

variable "infrastructure_support" {
  default     = "poornima.krishnasamy@digital.justice.gov.uk"
  description = "Cloud Platform"
}

variable "is_production" {
  default = "false"
}


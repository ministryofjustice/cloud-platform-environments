variable "domain" {
  default = "prisoner-search-dev.prison.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-prisoner-search"
}

variable "namespace" {
  default = "hmpps-prisoner-search-dev"
}


variable "vpc_name" {}

variable "kubernetes_cluster" {}


variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "syscon-devs"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "eks_cluster_name" {
}

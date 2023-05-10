variable "domain" {
  default = "hpa-preprod.prison.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-hpa-preprod"
}

variable "namespace" {
  default = "hmpps-hpa-preprod"
}


variable "eks_cluster_name" {
}

variable "vpc_name" {
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "haar"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "node-type" {
  default = "cache.t2.small"
}

variable "is_production" {
  default = "false"
}


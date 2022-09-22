variable "cluster_name" {
}

variable "vpc_name" {
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "domain" {
  default = "calculate-release-dates-api.hmpps.service.justice.gov.uk"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Calculate release dates API"
}

variable "namespace" {
  default = "calculate-release-dates-api-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "farsight-devs"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "calculate_release_dates"
}


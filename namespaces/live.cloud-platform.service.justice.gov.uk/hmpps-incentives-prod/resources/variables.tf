

variable "vpc_name" {
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Incentives Apps"
}

variable "namespace" {
  default = "hmpps-incentives-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-incentives"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
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
  default     = "incentives-dev"
}

# Database settings

variable "backup_window" {
  default = "22:00-23:59"
}

variable "maintenance_window" {
  default = "sun:00:00-sun:03:00"
}

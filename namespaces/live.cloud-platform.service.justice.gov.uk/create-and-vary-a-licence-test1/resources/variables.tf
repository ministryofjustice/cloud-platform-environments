

variable "vpc_name" {
}


variable "application" {
  description = "Name of Application you are deploying"
  default     = "create-and-vary-a-licence"
}

variable "namespace" {
  default = "create-and-vary-a-licence-test1"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "create-and-vary-a-licence-devs"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "test1"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "create-and-vary-a-licence"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}
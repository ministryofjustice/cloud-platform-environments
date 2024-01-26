

variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "MoJ Maintenance Pages"
}

variable "namespace" {
  default = "maintenance-pages"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "operations-engineering"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "operations-engineering@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "operations-engineering-team"
}

variable "domains" {
  description = "List of domains to be put in maintenance"
  type        = any
  default     = ["nomisqc.justice.gov.uk","operations-engineering.service.justice.gov.uk"]
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo."
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

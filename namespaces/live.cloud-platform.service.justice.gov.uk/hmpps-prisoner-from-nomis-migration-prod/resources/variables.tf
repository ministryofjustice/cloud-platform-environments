variable "vpc_name" {}

variable "kubernetes_cluster" {}

variable "domain" {
  default = "prisoner-nomis-migration.hmpps.service.justice.gov.uk"
}

variable "domain_sync_dashboard" {
  default = "nomis-sync-dashboard.hmpps.service.justice.gov.uk"
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Prisoner from NOMIS Migration"
}

variable "application_sync_dashboard" {
  description = "Name of Application you are deploying"
  default     = "HMPPS NOMIS Synchronisation Dashboard"
}

variable "namespace" {
  default = "hmpps-prisoner-from-nomis-migration-prod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "syscon-devs"
}

variable "environment_name" {
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
  default     = "syscon_team"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "node_type" {
  default = "cache.t4g.micro"
}

variable "eks_cluster_name" {}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  type        = string
  default     = "ministryofjustice"
}

variable "github_token" {
  type        = string
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

variable "kubernetes_cluster" {}

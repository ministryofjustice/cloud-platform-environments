
variable "cluster_name" {
}

variable "vpc_name" {
}

variable "cluster_state_bucket" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Elasticsearch storage test"
}

variable "namespace" {
  default = "swestest-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "webops"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platforms@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "cloud-platform"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "timestamp_field" {
  type        = string
  default     = "last_updated"
  description = "Field Kibana identifies as Time field, when creating the index pattern"
}

variable "warm_transition" {
  type        = string
  default     = "5d"
  description = "Time until transition to warm storage"
}

variable "cold_transition" {
  type        = string
  default     = "10d"
  description = "Time until transition to cold storage"
}

variable "delete_transition" {
  type        = string
  default     = "20d"
  description = "Time until indexes are permanently deleted"
}

variable "index_pattern" {
  default = [
    "test_data*",
  ]
  description = "Pattern created in Kibana, policy will apply to matching new indices"
}
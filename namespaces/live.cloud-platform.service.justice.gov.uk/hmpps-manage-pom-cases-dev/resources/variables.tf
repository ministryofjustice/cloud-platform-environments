variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "eks_cluster_name" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "hmpps-manage-pom-cases"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  default     = "hmpps-manage-pom-cases-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "manage-pom-cases"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "elephants@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  default     = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "manage-pom-cases"
}

variable "number_cache_clusters" {
  description = "The number of cache clusters (primary and replicas) this replication group will have. Default is 2"
  default     = "2"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the GitHub Terraform provider"
  default     = ""
}

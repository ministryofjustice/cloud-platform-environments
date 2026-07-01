variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Managing Prisoner Applications"
}

variable "namespace" {
  default = "hmpps-justice-data-agent-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-justice-data-agent-devs"
}

####################################################################################################################
### Change this environment to the environment name corresponding to this namespace (as per helm/values-ENV.dev) ###
variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}
####################################################################################################################

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "thehub@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "public-justice-data-agent" # need to create slack channel which  should be public and someone can post question if they need to ask
}

variable "number_cache_clusters" {
  default = "2"
}
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

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

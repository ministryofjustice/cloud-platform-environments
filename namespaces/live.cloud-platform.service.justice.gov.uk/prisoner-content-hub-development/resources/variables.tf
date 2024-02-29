variable "domain" {
  default = "content-hub.prisoner.service.justice.gov.uk/ "
}

variable "application" {
  default = "prisoner-content-hub"
}

variable "namespace" {
  default = "prisoner-content-hub-development"
}

# this is injected by Cloud Platform automatically so we do not need to populate it here

variable "vpc_name" {
}


variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

# We chose pfs because this variable is used to create domain names for resources
# e.g. ElasticSearch. When concatenated with the environment name and unique name,
# this only leaves a handful of characters for the team_name.
variable "team_name" {
  description = "DNS compliant name of the development team"
  default     = "pfs"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "development"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "thehub@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
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


variable "kubernetes_cluster" {}

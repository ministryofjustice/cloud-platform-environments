variable "domain" {
  default = "historical-prisoner-dev.prison.service.justice.gov.uk"
}

variable "application" {
  default = "hmpps-historical-prisoner-dev"
}

variable "namespace" {
  default = "hmpps-historical-prisoner-dev"
}


variable "eks_cluster_name" {
}

variable "vpc_name" {
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "development"
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
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "dps-hmpps@digital.justice.gov.uk"
}

variable "number_cache_clusters" {
  default = "2"
}

variable "node-type" {
  default = "cache.t4g.micro"
}

variable "is_production" {
  default = "false"
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

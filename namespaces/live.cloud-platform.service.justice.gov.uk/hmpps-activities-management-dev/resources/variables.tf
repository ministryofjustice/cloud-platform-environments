
variable "vpc_name" {
}


variable "application" {
  description = "Name of Application you are deploying"
  default     = "activities"
}

variable "namespace" {
  default = "hmpps-activities-management-dev"
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
  default     = "dev"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
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
  default     = "activities-management"
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

variable "rds_family" {
  default = "postgres14"
}

variable "mp_dps_sg_name" {
  type        = string
  description = "Required MP DPR Traffic ingress into DPS"
  default     = "cloudplatform-mp-dps-sg"
}


variable "kubernetes_cluster" {}

/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */
variable "vpc_name" {
}

variable "application" {
  default = "use-of-force"
}

variable "namespace" {
  default = "use-of-force-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "Move a Prisoner"
}

variable "deployment_team_name" {
  default = "move-a-prisoner"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "deployment_environment" {
  type = string
  description = "Environment code used when deploying, e.g. dev, preprod or prod"
  default = "preprod"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
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
  default     = "move-a-prisoner-digital"
}

variable "review_team_name" {
  default = "move-a-prisoner"
}

variable "number_cache_clusters" {
  default = "3"
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

variable "mp_dps_sg_name" {
  type        = string
  description = "Required for MP DPR Traffic ingress into CP DPS"
  default     = "cloudplatform-mp-dps-sg"
}

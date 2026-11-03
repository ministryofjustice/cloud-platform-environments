variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "HMPPS Electronic Monitoring Datastore"
}

variable "namespace" {
  default = "hmpps-electronic-monitoring-datastore-dev"
}

variable "namespace-short" {
  default = "hmpps-em-datastore-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "hmpps-em-probation-devs"
}

variable "service_area" {
  description = "Service area responsible for this service"
  default     = "Electronic Monitoring"
}

####################################################################################################################
### Change this environment to the environment name corresponding to this namespace (as per helm/values-ENV.dev) ###
variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hmpps-ems-platform-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "em-engineers-moj-madetech"
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

variable "em_datastore_general_role" {
  type        = string
  description = "Role assumed by the API and Algorithm to access the Electronic Monitoring Data Store"
  default     = "arn:aws:iam::396913731313:role/cmt_read_emds_data_test"
}

variable "em_datastore_specials_role" {
  type        = string
  description = "Role assumed by the API and Algorithm to access the Electronic Monitoring Data Store"
  default     = "arn:aws:iam::396913731313:role/specials_cmt_read_emds_data_test"
}

locals {
  namespace_yaml = yamldecode(file("${path.module}/../00-namespace.yaml"))
}

variable "vpc_name" {
}

variable "cluster_state_bucket" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = namespace_yaml.metadata.annotations["cloud-platform.justice.gov.uk/application"]
}

variable "namespace" {
  default = namespace_yaml.metadata.name
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = namespace_yaml.metadata.annotations["cloud-platform.justice.gov.uk/business-unit"]
}

variable "team_name" {
  description = "The name of your development team"
  default     = namespace_yaml.metadata.annotations["cloud-platform.justice.gov.uk/business-unit"]
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = namespace_yaml.metadata.labels["cloud-platform.justice.gov.uk/environment-name"]
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "platforms@digital.justice.gov.uk"
}

variable "is_production" {
  default = namespace_yaml.metadata.labels["cloud-platform.justice.gov.uk/is-production"]
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = namespace_yaml.metadata.annotations["cloud-platform.justice.gov.uk/slack-channel"]
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

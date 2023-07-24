

variable "vpc_name" {
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "laa-crime-maat-test"
}

variable "namespace" {
  default = "laa-crime-maat-test"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "LAA"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-crime-apps-team"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "test"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "anil.dhiman@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "laa-crime-maat-tests"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_TOKEN"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_CERT"
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  default     = "KUBE_CLUSTER_DEV"
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_NAMESPACE_DEV"
}


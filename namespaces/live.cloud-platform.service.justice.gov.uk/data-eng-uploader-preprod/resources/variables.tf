

variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "Analytical Platform Uploader"
}

variable "namespace" {
  default = "data-eng-uploader-preprod"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "Platforms"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "data-engineering"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "preprod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "prisonprobationdataengineering@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "data_engineering"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_NAMESPACE_PREPROD"
}
variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_CERT_PREPROD"
}
variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_TOKEN_PREPROD"
}
variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the serviceaccount cluster"
  default     = "KUBE_CLUSTER_PREPROD"
}

variable "github_actions_secret_ecr_name" {
  description = "The name of the github actions secret containing the ECR name"
  default     = "ECR_NAME_PREPROD"
}

variable "github_actions_secret_ecr_url" {
  description = "The name of the github actions secret containing the ECR URL"
  default     = "ECR_URL_PREPROD"
}

variable "github_actions_secret_ecr_access_key" {
  description = "The name of the github actions secret containing the ECR AWS access key"
  default     = "ECR_AWS_ACCESS_KEY_ID_PREPROD"
}

variable "github_actions_secret_ecr_secret_key" {
  description = "The name of the github actions secret containing the ECR AWS secret key"
  default     = "ECR_AWS_SECRET_ACCESS_KEY_PREPROD"
}

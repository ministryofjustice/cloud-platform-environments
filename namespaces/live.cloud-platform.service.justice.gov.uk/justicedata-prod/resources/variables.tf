
variable "vpc_name" {
}

variable "kubernetes_cluster" {
}
variable "cluster_state_bucket" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "justicedata publication portal for hmpp"
}

variable "namespace" {
  default = "justicedata-prod"
}

variable "domain" {
  default = "data.justice.gov.uk"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "justicedata"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "production"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "hubusers@justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "owner" {
  description = "Required by the route53"
  default     = "ministryofjustice"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "performance-hub-dev"
}

variable "github_owner" {
  description = "Required by the github terraform provider"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the github terraform provider"
  default     = ""
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_PROD_NAMESPACE"
}
variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_PROD_CERT"
}
variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_PROD_TOKEN"
}
variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the serviceaccount cluster"
  default     = "KUBE_PROD_CLUSTER"
}

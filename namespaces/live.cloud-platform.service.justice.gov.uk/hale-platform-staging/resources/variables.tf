

variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "hale-platform"
}

variable "namespace" {
  default = "hale-platform-staging"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HQ"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "jotw-content-devs"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "staging"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "wordpress@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "wordpress-gang"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the kubernetes cluster name"
  default     = "KUBE_CLUSTER"
}

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_NAMESPACE"
}

variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_CERT"
}

variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_TOKEN"
}

variable "bucket_arns" {
  type    = list(string)
  default = [
    "arn:aws:s3:::lawcom-prod-storage-11jsxou24uy7q",
    "arn:aws:s3:::cloud-platform-e218f50a4812967ba1215eaecede923f/*", # prod
    "arn:aws:s3:::cloud-platform-e8ef9051087439cca56bf9caa26d0a3f/*", # dev
    "arn:aws:s3:::cloud-platform-f90b68639e12a88881c27434d72d6119/*", # demo
    "arn:aws:s3:::lawcom-prod-storage-11jsxou24uy7q/*", # tacticalproducts legacy account
    "arn:aws:s3:::justicejobs-prod-storage-u1mo8w50uvqm/*", # tacticalproducts legacy account
    "arn:aws:s3:::sifocc-prod-storage-7f6qtyoj7wir/*", # tacticalproducts legacy account
    "arn:aws:s3:::npm-prod-storage-19n0nag2nk8xk/*", # tacticalproducts legacy account
    "arn:aws:s3:::layobservers-prod-storage-nu2yj19yczbd/*" # tacticalproducts legacy account
  ]
}


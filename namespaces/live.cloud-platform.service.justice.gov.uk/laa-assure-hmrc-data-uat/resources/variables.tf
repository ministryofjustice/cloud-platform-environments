variable "vpc_name" {
  description = "VPC name to create security groups in for the ElastiCache and RDS modules"
  type        = string
}

variable "kubernetes_cluster" {
  description = "Kubernetes cluster name for references to secrets for service accounts"
  type        = string
}

variable "application" {
  description = "Name of the application you are deploying"
  type        = string
  default     = "Assure HMRC data"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-assure-hmrc-data-uat"
}

variable "repo_name" {
  default = "laa-assure-hmrc-data"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "laa-apply-for-legal-aid"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "uat"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "apply-for-civil-legal-aid@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "apply-dev"
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

variable "github_actions_secret_kube_namespace" {
  description = "The name of the github actions secret containing the kubernetes namespace name"
  default     = "KUBE_UAT_NAMESPACE"
}
variable "github_actions_secret_kube_cert" {
  description = "The name of the github actions secret containing the serviceaccount ca.crt"
  default     = "KUBE_UAT_CERT"
}
variable "github_actions_secret_kube_token" {
  description = "The name of the github actions secret containing the serviceaccount token"
  default     = "KUBE_UAT_TOKEN"
}
variable "github_actions_secret_kube_cluster" {
  description = "The name of the github actions secret containing the serviceaccount cluster"
  default     = "KUBE_UAT_CLUSTER"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "serviceaccount_rules" {
  description = "The capabilities of this serviceaccount"

  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))

  # These values are default plus custom to allow for deletion of UAT branches via CI/CD pipeline
  default = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "pods",
        "configmaps",
        "persistentvolumeclaims",
        "serviceaccounts",
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "update",
        "delete",
        "list",
        "watch",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
        "monitoring.coreos.com",
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "replicasets",
        "statefulsets",
        "poddisruptionbudgets",
        "servicemonitors",
        "prometheusrules",
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch",
      ]
    },
  ]
}

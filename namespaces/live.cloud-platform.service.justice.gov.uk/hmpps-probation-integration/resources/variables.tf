

variable "vpc_name" {
}

variable "kubernetes_cluster" {
}

variable "application" {
  description = "Name of Application you are deploying"
  default     = "probation-integration"
}

variable "namespace" {
  default = "hmpps-probation-integration"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "HMPPS"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "probation-integration"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "prod"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "probation-integration-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "true"
}

variable "slack_channel" {
  description = "Team slack channel to use if we need to contact your team"
  default     = "probation-integration-team"
}

variable "github_owner" {
  description = "The GitHub organization or individual user account containing the app's code repo. Used by the Github Terraform provider. See: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/getting-started/ecr-setup.html#accessing-the-credentials"
  default     = "ministryofjustice"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

variable "domain" {
  default = "probation-integration.service.justice.gov.uk"
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

variable "serviceaccount_rules" {
  description = "The capabilities of this service account"

  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))

  default = [
    {
      api_groups = [""]
      resources  = ["pods/log"]
      verbs      = ["get"]
    },
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "pods/exec",
        "pods/attach",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods"
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "delete",
        "list",
        "watch",
        "update",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "networking.k8s.io",
        "certmanager.k8s.io",
        "policy",
        "monitoring.coreos.com",
        "batch",
      ]
      resources = [
        "deployments",
        "deployments/scale",
        "ingresses",
        "replicasets",
        "poddisruptionbudgets",
        "certificates",
        "networkpolicies",
        "servicemonitors",
        "prometheusrules",
        "cronjobs",
        "jobs",
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

variable "maintenance_window" {
  default = "sun:00:00-sun:03:00"
}
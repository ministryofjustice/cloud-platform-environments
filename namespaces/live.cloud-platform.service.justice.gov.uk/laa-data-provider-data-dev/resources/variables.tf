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
  default     = "Provider data"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-data-provider-data-dev"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "laa-data-stewardship-cse-team"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "development"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "laa-dstew-enterprise@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-data-stewardship-enterprise"
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

### Additions

variable "eks_cluster_name" {
  description = "Required by the cloud-platform-terraform-secrets-manager module"
  type        = string
}

variable "github_repository_names" {
  description = "Used to create GitHub secrets into the right GitHub repositories"
  type        = list(string)
  default     = [
    "laa-data-provider-data",
    "laa-provider-data-platform"
  ]
}

variable "github_environment_name" {
  description = "Used to create GitHub secrets into the right GitHub environment"
  type        = string
  default     = "dev"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "Common Services and Enterprise"
}

variable "serviceaccount_rules" {
  description = "The capabilities of this service account"

  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))

  ### See https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/03ed80145d5d39c43055ea8208a5f55cbb659fa4/variables.tf#L20-L107
  default = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",  ### typo, but see api_group "apps", resource "deployments" below
        "secrets",
        "services",
        "configmaps",
        "pods",
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
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "poddisruptionbudgets",
        "networkpolicies",
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
    {
      api_groups = [
        "monitoring.coreos.com",
      ]
      resources = [
        "prometheusrules",
        "servicemonitors",
      ]
      verbs = [
        "*",
      ]
    },
    {
      api_groups = [
        "autoscaling",
      ]
      resources = [
        "hpa",  ### typo, but see resource "horizontalpodautoscalers" below
        "horizontalpodautoscalers",
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
      ]
    },
    ### Addition to allow service account to scale deployments
    {
      api_groups = [
        "apps",
      ]
      resources = [
        "deployments/scale",
      ]
      verbs = [
        "get",
        "update",
        "patch",
      ]
    },
  ]
}

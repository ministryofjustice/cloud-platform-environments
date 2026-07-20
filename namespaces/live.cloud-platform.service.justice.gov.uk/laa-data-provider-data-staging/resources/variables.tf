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
  default     = "laa-data-provider-data-staging"
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
  default     = "staging"
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
  default     = "staging"
}

variable "service_area" {
  description = "Service area responsible for this service"
  type        = string
  default     = "Common Services and Enterprise"
}

variable "serviceaccount_rules" {
  description = "The capabilities of the legacy cd-serviceaccount"
  type = list(object({api_groups = list(string), resources = list(string), verbs = list(string)}))
  ### See https://github.com/ministryofjustice/cloud-platform-terraform-serviceaccount/blob/dabba75ea181b627f17e2844bdd1608fbda824d5/variables.tf#L20-L107
  default = [{
    api_groups = [""]
    resources  = ["pods/portforward", "deployment", "secrets", "services", "configmaps", "pods"]
    verbs      = ["patch", "get", "create", "update", "delete", "list", "watch"]
  }, {
    api_groups = ["extensions", "apps", "batch", "networking.k8s.io", "policy"]
    resources  = ["deployments", "ingresses", "cronjobs", "jobs", "replicasets", "poddisruptionbudgets", "networkpolicies"]
    verbs      = ["get", "update", "delete", "create", "patch", "list", "watch"]
  }, {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["prometheusrules", "servicemonitors"]
    verbs      = ["*"]
  }, {
    api_groups = ["autoscaling"]
    resources  = ["hpa", "horizontalpodautoscalers"]
    verbs      = ["get", "update", "delete", "create", "patch"]
  }, {
    ### Addition to allow the 'cd-serviceaccount' service account to scale deployments
    api_groups = ["apps"]
    resources  = ["deployments/scale"]
    verbs      = ["get", "update", "patch"]
  }]
}

variable "deployer_serviceaccount_rules" {
  description = "Least-privilege rules for the deployer service account (Helm-managed resources)"
  type = list(object({api_groups = list(string), resources = list(string), verbs = list(string)}))
  default = [{
    api_groups = [""]
    resources  = ["configmaps", "services", "secrets"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }, {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }, {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses", "networkpolicies"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }, {
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }, {
    api_groups = ["monitoring.coreos.com"]
    resources  = ["prometheusrules", "servicemonitors"]
    verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
  }]
}

variable "e2etester_serviceaccount_rules" {
  description = "Least-privilege rules for the e2etester service account (read-only + port-forward)"
  type = list(object({api_groups = list(string), resources = list(string), verbs = list(string)}))
  default = [{
    api_groups = [""]
    resources  = ["services", "pods"]
    verbs      = ["get", "list", "watch"]
  }, {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["get", "list", "watch"]
  }, {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["create"]
  }]
}

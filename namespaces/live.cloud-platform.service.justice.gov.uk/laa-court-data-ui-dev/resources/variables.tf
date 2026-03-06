variable "application" {
  default = "laa-court-data-ui"
}

variable "namespace" {
  default = "laa-court-data-ui-dev"
}

variable "domain" {
  default = "view-court-data.service.justice.gov.uk"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "legal-aid-agency"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-access-court-data"
}

variable "repo_name" {
  description = "The name of github repo AND ecr repo"
  default     = "laa-court-data-ui"
}

variable "environment-name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "access-court-data-team@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

/*
 * When using this module through the cloud-platform-environments, the following
 * variable is automatically supplied by the pipeline.
 *
 */

variable "vpc_name" {
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


variable "kubernetes_cluster" {}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "service_area" {
  description = "Service area responsible for this service"
  default     = "Criminal Applications"
}

variable "serviceaccount_rules" {
  description = "The capabilities of this serviceaccount"

  type = list(object({
    api_groups = list(string),
    resources  = list(string),
    verbs      = list(string)
  }))

  # These values are usually sufficient for a CI/CD pipeline
  default = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "serviceaccounts",
        "pods",
        "pods/exec",
        "configmaps",
        "persistentvolumeclaims",
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "update",
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
        "batch",
        "networking.k8s.io",
        "monitoring.coreos.com",
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "statefulsets",
        "servicemonitors",
        "networkpolicies",
        "poddisruptionbudgets",
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
    }
  ]
}

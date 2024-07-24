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
  default     = "crime-applications-adaptor"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-crime-applications-adaptor-test"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "LAA"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "laa-crime-apps-team"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "test"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "laa-crime-apps@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-crimeapps-core"
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

variable "encrypt_sqs_kms" {
  description = "Encrypt sqs keys."
  default     = "false"
}

variable "message_retention_seconds" {
  description = "The number of seconds Amazon SQS retains a message. Integer representing seconds, from 60 (1 minute) to 1209600 (14 days)."
  default     = "1209600"
}

variable "visibility_timeout_seconds" {
  description = "Sets the length of time (seconds) that a message received from a queue will not be visible to the other message consumers."
  default     = "120"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "user_pool_name" {
  description = "Cognito user pool name"
  default     = "caa-api-test-userpool"
}

variable "cognito_user_pool_client_name" {
  description = "Cognito user pool client name"
  default     = "maat-application"
}

variable "resource_server_identifier" {
  description = "Cognito resource server identifier"
  default     = "caa-api-test"
}

variable "resource_server_name" {
  description = "Cognito resource server name"
  default     = "caa-api-test-resource-server"
}

variable "resource_server_scope_name" {
  description = "Resource server scope name"
  default     = "standard"
}

variable "resource_server_scope_description" {
  default = "Standard scope"
}

variable "cognito_user_pool_domain_name" {
  default = "caa-api-test"
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
      resources  = ["pods/exec"]
      verbs      = ["create"]
    },
    {
    "api_groups": [""],
    "resources": [
      "pods/portforward",
      "deployment",
      "secrets",
      "services",
      "configmaps",
      "pods"
    ],
    "verbs": [
      "patch",
      "get",
      "create",
      "update",
      "delete",
      "list",
      "watch"
    ]
  },
  {
    "api_groups": [
      "extensions",
      "apps",
      "batch",
      "networking.k8s.io",
      "policy"
    ],
    "resources": [
      "deployments",
      "ingresses",
      "cronjobs",
      "jobs",
      "replicasets",
      "poddisruptionbudgets",
      "networkpolicies"
    ],
    "verbs": [
      "get",
      "update",
      "delete",
      "create",
      "patch",
      "list",
      "watch"
    ]
  },
  {
    "api_groups": [
      "monitoring.coreos.com"
    ],
    "resources": [
      "prometheusrules",
      "servicemonitors"
    ],
    "verbs": [
      "*"
    ]
  },
  {
    "api_groups": [
      "autoscaling"
    ],
    "resources": [
      "hpa",
      "horizontalpodautoscalers"
    ],
    "verbs": [
      "get",
      "update",
      "delete",
      "create",
      "patch"
    ]
  }
  ]
}
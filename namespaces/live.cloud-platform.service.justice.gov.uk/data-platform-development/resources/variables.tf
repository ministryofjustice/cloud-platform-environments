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
  default     = "Data Platform"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "data-platform-development"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for this service"
  type        = string
  default     = "Platforms"
}

variable "team_name" {
  description = "Name of the development team responsible for this service"
  type        = string
  default     = "data-platform-cloud-platform-development"
}

variable "environment" {
  description = "Name of the environment type for this service"
  type        = string
  default     = "development"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "data-platform-tech@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "false"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "data-platform-tech"
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

variable "access_accounts" {
  type        = list(string)
  description = "Destination accounts for S3 access"
  default = [
    "013433889002", # data-platform-development
    "803963757240", # ap-data-d
    "189157455002", # ap-data-eng
    "684969100054", # ap-data-eng-a
    "593291632749", # ap-data
    "525294151996", # ap-dev
    "312423030077"  # ap
  ]
}

variable "datahub-frontend-sa" {
  type        = string
  description = "Datahub service account used for deployment"
  default     = "datahub-datahub-frontend"
}

variable "datahub-gms-sa" {
  type        = string
  description = "Datahub GMS service account used for data ingestion"
  default     = "datahub-datahub-gms"
}

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "github_actions_secret_ecr_name" {
  description = "The name of the github actions secret containing the ECR name"
  default     = "ECR_NAME_DEV"
}

variable "github_actions_secret_ecr_url" {
  description = "The name of the github actions secret containing the ECR URL"
  default     = "ECR_URL_DEV"
}

variable "github_actions_secret_ecr_access_key" {
  description = "The name of the github actions secret containing the ECR AWS access key"
  default     = "ECR_AWS_ACCESS_KEY_ID_DEV"
}

variable "github_actions_secret_ecr_secret_key" {
  description = "The name of the github actions secret containing the ECR AWS secret key"
  default     = "ECR_AWS_SECRET_ACCESS_KEY_DEV"
}

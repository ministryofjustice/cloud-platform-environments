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
  default     = "maat-data-api"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-maat-data-api-prod"
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
  default     = "production"
}

variable "infrastructure_support" {
  description = "Email address of the team responsible this service"
  type        = string
  default     = "laacrimeapps@justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-crimeapps"
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

variable "eks_cluster_name" {
  description = "The name of the eks cluster to retrieve the OIDC information"
}

variable "environment_name" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "user_pool_name" {
  description = "Cognito user pool name"
  default     = "maat-api-prod-userpool"
}

variable "cognito_user_pool_client_name_maat_orch" {
  description = "Cognito user pool client - MAAT Orchestration"
  default     = "maat-orchestration-prod"
}

variable "cognito_user_pool_client_name_cma" {
  description = "Cognito user pool client - CMA"
  default     = "cma-prod"
}

variable "cognito_user_pool_client_name_ccp" {
  description = "Cognito user pool client - CCP"
  default     = "ccp-prod"
}

variable "cognito_user_pool_client_name_ccc" {
  description = "Cognito user pool client - CCC"
  default     = "ccc-prod"
}

variable "cognito_user_pool_client_name_ats" {
  description = "Cognito user pool client - ATS"
  default     = "ats-prod"
}

variable "cognito_user_pool_client_name_evidence" {
  description = "Cognito user pool client - Evidence"
  default     = "evidence-prod"
}

variable "cognito_user_pool_client_name_cda" {
  description = "Cognito user pool client - CDA"
  default     = "cda-prod"
}

variable "cognito_user_pool_client_name_caa" {
  description = "Cognito user pool client - CAA"
  default     = "caa-prod"
}

variable "cognito_user_pool_client_name_hardship" {
  description = "Cognito user pool client - Hardship"
  default     = "hardship-prod"
}

variable "cognito_user_pool_client_name_dces_report" {
  description = "Cognito user pool client - DCES Report"
  default     = "dces-report-prod"
}

variable "cognito_user_pool_client_name_dces_drc" {
  description = "Cognito user pool client - DCES DRC Integration"
  default     = "dces-drc-prod"
}

variable "cognito_user_pool_client_name_cccd" {
  description = "Cognito user pool client - CCCD"
  default     = "cccd-prod"
}

variable "cognito_user_pool_client_name_mlra" {
  description = "Cognito user pool client - MLRA"
  default     = "mlra-prod"
}

variable "cognito_user_pool_client_name_cas" {
  description = "Cognito user pool client - Crime Assessment Service"
  default     = "cas-prod"
}

variable "resource_server_identifier" {
  description = "Cognito resource server identifier"
  default     = "maat-api-prod"
}

variable "resource_server_name" {
  description = "Cognito resource server name"
  default     = "maat-api-prod-resource-server"
}

variable "resource_server_scope_name" {
  description = "Resource server scope name"
  default     = "standard"
}

variable "resource_server_scope_description" {
  default = "Standard scope"
}

variable "cognito_user_pool_domain_name" {
  default = "maat-api-prod"
}

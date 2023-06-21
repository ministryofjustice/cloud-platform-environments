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
  default     = "crime-auth"
}

variable "namespace" {
  description = "Name of the namespace these resources are part of"
  type        = string
  default     = "laa-crime-auth"
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
  default     = "laa-crime-apps@digital.justice.gov.uk"
}

variable "is_production" {
  description = "Whether this environment type is production or not"
  type        = string
  default     = "true"
}

variable "slack_channel" {
  description = "Slack channel name for your team, if we need to contact you about this service"
  type        = string
  default     = "laa-crime-apps"
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

variable "user_pool_name" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool"
}

variable "cognito_user_pool_ccp_client_name_dev" {
  description = "Cognito user pool CCP client name"
  default     = "crown-court-proceeding-client-dev"
}

variable "cognito_user_pool_ccp_client_name_tst" {
  description = "Cognito user pool CCP client name"
  default     = "crown-court-proceeding-client-tst"
}

variable "cognito_user_pool_ccp_client_name_uat" {
  description = "Cognito user pool CCP client name"
  default     = "crown-court-proceeding-client-uat"
}

variable "cognito_user_pool_ccp_client_name_stg" {
  description = "Cognito user pool CCP client name"
  default     = "crown-court-proceeding-client-stg"
}

variable "cognito_user_pool_ccp_client_name_prd" {
  description = "Cognito user pool CCP client name"
  default     = "crown-court-proceeding-client-prd"
}

variable "cognito_user_pool_ccc_client_name_dev" {
  description = "Cognito user pool CCC client name"
  default     = "crown-court-contribution-client-dev"
}

variable "cognito_user_pool_ccc_client_name_tst" {
  description = "Cognito user pool CCC client name"
  default     = "crown-court-contribution-client-tst"
}

variable "cognito_user_pool_ccc_client_name_uat" {
  description = "Cognito user pool CCC client name"
  default     = "crown-court-contribution-client-uat"
}

variable "cognito_user_pool_ccc_client_name_stg" {
  description = "Cognito user pool CCC client name"
  default     = "crown-court-contribution-client-stg"
}

variable "cognito_user_pool_ccc_client_name_prd" {
  description = "Cognito user pool CCC client name"
  default     = "crown-court-contribution-client-prd"
}

variable "evidence_resource_server_identifier" {
  default     = "evidence"
  description = "Cognito resource server identifier"
}

variable "evidence_resource_server_name" {
  default     = "evidence-resource-server"
  description = "Cognito resource server name"
}

variable "evidence_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "evidence_scope_description" {
  default = "Standard scope for the Crime Evidence service"
}

variable "hardship_resource_server_identifier" {
  default     = "hardship"
  description = "Cognito resource server identifier for Crime Hardship service"
}

variable "hardship_resource_server_name" {
  default     = "hardship-resource-server"
  description = "Cognito resource server name for Crime Hardship service"
}

variable "hardship_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "hardship_scope_description" {
  default = "Standard scope for the Crime Hardship service"
}

variable "cognito_user_pool_domain_name" {
  default = "laa-crime-auth"
}

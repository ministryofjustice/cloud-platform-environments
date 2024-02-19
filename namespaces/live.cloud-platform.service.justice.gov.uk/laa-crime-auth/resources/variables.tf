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

variable "user_pool_name_evidence" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-evidence"
}

variable "user_pool_name_ats" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-ats"
}

variable "user_pool_name_hardship" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-hardship"
}

variable "user_pool_name_cma" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-cma"
}

variable "user_pool_name_ccp" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-ccp"
}

variable "user_pool_name_ccc" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-ccc"
}

variable "user_pool_name_orchestration" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-orchestration"
}

variable "user_pool_name_validation" {
  description = "Cognito user pool name"
  default     = "laa-crime-auth-userpool-validation"
}

variable "cognito_user_pool_cma_client_name_dev" {
  description = "Cognito user pool CMA client name"
  default     = "crime-means-assessment-client-dev"
}

variable "cognito_user_pool_cma_client_name_tst" {
  description = "Cognito user pool CMA client name"
  default     = "crime-means-assessment-client-tst"
}

variable "cognito_user_pool_cma_client_name_uat" {
  description = "Cognito user pool CMA client name"
  default     = "crime-means-assessment-client-uat"
}

variable "cognito_user_pool_cma_client_name_prd" {
  description = "Cognito user pool CMA client name"
  default     = "crime-means-assessment-client-prd"
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

variable "cognito_user_pool_ccc_client_name_prd" {
  description = "Cognito user pool CCC client name"
  default     = "crown-court-contribution-client-prd"
}

variable "cognito_user_pool_orchestration_client_name_dev" {
  description = "Cognito user pool Orchestration client name"
  default     = "maat-orchestration-client-dev"
}

variable "cognito_user_pool_orchestration_client_name_tst" {
  description = "Cognito user pool Orchestration client name"
  default     = "maat-orchestration-client-tst"
}

variable "cognito_user_pool_orchestration_client_name_uat" {
  description = "Cognito user pool Orchestration client name"
  default     = "maat-orchestration-client-uat"
}

variable "cognito_user_pool_orchestration_client_name_prd" {
  description = "Cognito user pool Orchestration client name"
  default     = "maat-orchestration-client-prd"
}

variable "cognito_user_pool_maat_client_name_dev" {
  description = "Cognito user pool MAAT client name"
  default     = "maat-client-dev"
}

variable "cognito_user_pool_maat_client_name_tst" {
  description = "Cognito user pool MAAT client name"
  default     = "maat-client-tst"
}

variable "cognito_user_pool_maat_client_name_uat" {
  description = "Cognito user pool MAAT client name"
  default     = "maat-client-uat"
}

variable "cognito_user_pool_maat_client_name_stg" {
  description = "Cognito user pool MAAT client name"
  default     = "maat-client-stg"
}

variable "cognito_user_pool_maat_client_name_prd" {
  description = "Cognito user pool MAAT client name"
  default     = "maat-client-prd"
}

variable "cognito_user_pool_maat_os_client_name_dev" {
  description = "Cognito user pool MAAT OS client name"
  default     = "maat-os-client-dev"
}

variable "cognito_user_pool_maat_os_client_name_tst" {
  description = "Cognito user pool MAAT OS client name"
  default     = "maat-os-client-tst"
}

variable "cognito_user_pool_maat_os_client_name_uat" {
  description = "Cognito user pool MAAT OS client name"
  default     = "maat-os-client-uat"
}

variable "cognito_user_pool_maat_os_client_name_prd" {
  description = "Cognito user pool MAAT OS client name"
  default     = "maat-os-client-prd"
}

variable "cognito_user_pool_cfe_client_name_dev" {
  description = "Cognito user pool CFE client name"
  default     = "cfe-client-dev"
}

variable "cognito_user_pool_cfe_client_name_tst" {
  description = "Cognito user pool CFE client name"
  default     = "cfe-client-tst"
}

variable "cognito_user_pool_cfe_client_name_uat" {
  description = "Cognito user pool CFE client name"
  default     = "cfe-client-uat"
}

variable "cognito_user_pool_cfe_client_name_prd" {
  description = "Cognito user pool CFE client name"
  default     = "cfe-client-prd"
}

variable "cognito_user_pool_hardship_client_name_dev" {
  description = "Cognito user pool hardship client name"
  default     = "hardship-client-dev"
}

variable "cognito_user_pool_hardship_client_name_tst" {
  description = "Cognito user pool hardship client name"
  default     = "hardship-client-tst"
}

variable "cognito_user_pool_hardship_client_name_uat" {
  description = "Cognito user pool hardship client name"
  default     = "hardship-client-uat"
}

variable "cognito_user_pool_hardship_client_name_prd" {
  description = "Cognito user pool hardship client name"
  default     = "hardship-client-prd"
}

variable "cognito_user_pool_functional_tests_name" {
  description = "Cognito user pool functional tests client name"
  default     = "functional-tests-client"
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

variable "ats_resource_server_identifier" {
  default     = "ats"
  description = "Cognito resource server identifier"
}

variable "ats_resource_server_name" {
  default     = "ats-resource-server"
  description = "Cognito resource server name"
}

variable "ats_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "ats_scope_description" {
  default = "Standard scope for the Crime Application Tracking Service"
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

variable "cma_resource_server_identifier" {
  default     = "cma"
  description = "Cognito resource server identifier for Crime Means Assessment service"
}

variable "cma_resource_server_name" {
  default     = "cma-resource-server"
  description = "Cognito resource server name for Crime Means Assessment service"
}

variable "cma_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "cma_scope_description" {
  default = "Standard scope for the Crime Means Assessment service"
}

variable "ccp_resource_server_identifier" {
  default     = "ccp"
  description = "Cognito resource server identifier for Crime Means Assessment service"
}

variable "ccp_resource_server_name" {
  default     = "ccp-resource-server"
  description = "Cognito resource server name for Crown Court Proceeding service"
}

variable "ccp_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "ccp_scope_description" {
  default = "Standard scope for the Crown Court Proceeding service"
}

variable "ccc_resource_server_identifier" {
  default     = "ccc"
  description = "Cognito resource server identifier for Crown Court Contribution service"
}

variable "ccc_resource_server_name" {
  default     = "ccc-resource-server"
  description = "Cognito resource server name for Crown Court Contribution service"
}

variable "ccc_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "ccc_scope_description" {
  default = "Standard scope for the Crown Court Contribution service"
}

variable "orchestration_resource_server_identifier" {
  default     = "orchestration"
  description = "Cognito resource server identifier for MAAT Orchestration service"
}

variable "orchestration_resource_server_name" {
  default     = "orchestration-resource-server"
  description = "Cognito resource server name for MAAT Orchestration service"
}

variable "orchestration_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "orchestration_scope_description" {
  default = "Standard scope for the MAAT Orchestration service"
}

variable "validation_resource_server_identifier" {
  default     = "validation"
  description = "Cognito resource server identifier for Crime Validation service"
}

variable "validation_resource_server_name" {
  default     = "validation-resource-server"
  description = "Cognito resource server name for Crime Validation service all env"
}

variable "validation_scope_name" {
  default     = "standard"
  description = "Resource server scope name"
}

variable "validation_scope_description" {
  default = "Standard scope for the Crime Validation service"
}

variable "cognito_user_pool_domain_name_evidence" {
  default = "laa-crime-auth-evidence"
}

variable "cognito_user_pool_domain_name_ats" {
  default = "laa-crime-auth-ats"
}

variable "cognito_user_pool_domain_name_hardship" {
  default = "laa-crime-auth-hardship"
}

variable "cognito_user_pool_domain_name_cma" {
  default = "laa-crime-auth-cma"
}

variable "cognito_user_pool_domain_name_ccp" {
  default = "laa-crime-auth-ccp"
}

variable "cognito_user_pool_domain_name_ccc" {
  default = "laa-crime-auth-ccc"
}

variable "cognito_user_pool_domain_name_orchestration" {
  default = "laa-crime-auth-orchestration"
}

variable "cognito_user_pool_domain_name_validation" {
  default = "laa-crime-auth-validation"
}
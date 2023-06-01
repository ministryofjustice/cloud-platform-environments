variable "api_gateway_name" {
  description = "The name of the API Gateway"
  default = "caa-api-gateway"
}

variable "aws_lb_listener_https_arn" {
  description = "Load balancer listner arn"
  default = "https://laa-crime-applications-adaptor-prototype.legalservices.gov.uk/test"
}

variable "apigw_stage_name" {
  description = "Named reference to the deployment"
  default = "v1"
}

variable "user_pool_name" {
  description = "Cognito user pool name"
  default = "laa-crime-applications-adaptor-prototype-userpool"
}

variable "cognito_user_pool_client_name" {
  description = "Cognito user pool client name"
  default = "laa-crime-applications-adaptor-prototype"
}

variable "resource_server_identifier" {
  description = "Cognito resource server identifier"
  default = "laa-crime-applications-adaptor-prototype"
}

variable "resource_server_name" {
  description = "Cognito resource server name"
  default = "laa-crime-applications-adaptor-prototype-resourceserver"

}

variable "resource_server_scope_name" {
  description = "Resource server scope name"
  default = "standard"

}

variable "resource_server_scope_description" {
  default = "Standard scope"
}

variable "cognito_user_pool_domain_name" {
  default = "laa-crime-applications-adaptor-prototype"
}

variable "access_log_retention_in_days" {
  default = 7
}

variable "vpc_name" {
}


variable "kubernetes_cluster" {
}

variable "apigw_sg" {
  default = ""
}

variable "VPCSubnets" {
  default = ""
}

variable "apigw_region" {
  default = "eu-west-2"
}


variable "application" {
  description = "Name of Application you are deploying"
  default     = "Crime Application Adaptor Prototype"
}

variable "namespace" {
  default = "laa-crime-applications-adaptor-prototype"
}

variable "business_unit" {
  description = "Area of the MOJ responsible for the service."
  default     = "LAA"
}

variable "team_name" {
  description = "The name of your development team"
  default     = "laa-crime-apps-team"
}

variable "environment" {
  description = "The type of environment you're deploying to."
  default     = "dev"
}

variable "environment_name" {
  description = "The name of environment"
  default     = "dev"
}

variable "environment_suffix" {
  description = "The name of environment"
  default     = "dev"
}

variable "infrastructure_support" {
  description = "The team responsible for managing the infrastructure. Should be of the form team-email."
  default     = "laa-crime-apps-core@digital.justice.gov.uk"
}

variable "is_production" {
  default = "false"
}

variable "base_domain" {
  description = "Base domain where to create the custom hostname"
  default     = "legalservices.gov.uk"
}

variable "hostname" {
  description = "Host part of the FQDN"
  default     = "laa-crime-applications-adaptor-prototype"
}

variable "base_domain_route53_namespace" {
  description = "Kubernetes namespace where the base domain was created"
  default     = "laa-crime-applications-adaptor-prototype"
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
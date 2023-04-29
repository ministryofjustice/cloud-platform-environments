variable "api_gateway_name" {
  description = "The name of the API Gateway"
  default = "api-gateway"
}

variable "aws_lb_listener_https_arn" {
  description = "Load balancer listner arn"
  default = "https://crimeapply-adapter-integration-prototype.legalservices.gov.uk/test"
}

variable "apigw_stage_name" {
  description = "Named reference to the deployment"
  default = "v1"
}

variable "user_pool_name" {
  description = "Cognito user pool name"
  default = "crime-apply-integration-adapter-userpool"
}

variable "cognito_user_pool_client_name" {
  description = "Cognito user pool client name"
  default = "crime-apply-integration-adapter"
}

variable "resource_server_identifier" {
  description = "Cognito resource server identifier"
  default = "crime-apply-integration-adapter"
}

variable "resource_server_name" {
  description = "Cognito resource server name"
  default = "crime-apply-integration-adapter-resourceserver"

}

variable "resource_server_scope_name" {
  description = "Resource server scope name"
  default = "standard"

}

variable "resource_server_scope_description" {
    default = "Standard scope"
}

variable "cognito_user_pool_domain_name" {
     default = "crime-apply-integration-adapter-prototype"
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
  default     = "Crime Apply Integration Adapter"
}

variable "namespace" {
  default = "laa-crime-apply-integration-adapter-prototype"
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
  default     = "crimeapply-adapter-integration-prototype"
}

variable "base_domain_route53_namespace" {
  description = "Kubernetes namespace where the base domain was created"
  default     = "laa-crime-apply-integration-adapter-prototype"
}

variable "github_token" {
  description = "Required by the Github Terraform provider"
  default     = ""
}

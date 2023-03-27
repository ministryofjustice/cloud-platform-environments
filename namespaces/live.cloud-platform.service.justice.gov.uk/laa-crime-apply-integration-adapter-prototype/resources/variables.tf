variable "api_gateway_name" {
  description = "The name of the API Gateway"
  default = "api-gateway"
}

variable "aws_lb_listener_https_arn" {
  description = "Load balancer listner arn"
  default = ""
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

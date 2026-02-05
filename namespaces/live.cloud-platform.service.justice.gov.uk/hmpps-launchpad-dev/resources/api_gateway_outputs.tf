output "api_gateway_id" {
  description = "The ID of the API Gateway"
  value       = aws_api_gateway_rest_api.api_gateway_lp_auth.id
}

output "api_gateway_invoke_url" {
  description = "Internal URL to invoke the API Gateway"
  value       = aws_api_gateway_stage.main.invoke_url
}

output "api_gateway_authorize_endpoint" {
  description = "Full URL for authorize endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/v1/oauth2/authorize"
}

output "api_gateway_token_endpoint" {
  description = "Full URL for token endpoint"
  value       = "${aws_api_gateway_stage.main.invoke_url}/v1/oauth2/token"
}

output "api_gateway_external_client_url" {
  description = "Domain URL for external clients to use"
  value       = "https://${var.hostname}.${var.base_domain}"
}

output "api_gateway_api_key_secret_names" {
  description = "Map of API client names to Kubernetes secret names"
  value = {
    for k, v in kubernetes_secret.api_gateway_api_keys : k => v.metadata[0].name
  }
}

# Internal NLB IP addresses to add to ingress allowlist
output "internal_nlb_ip_addresses" {
  description = "Private IP addresses of the internal NLB - Add these to Ingress Allow List in values-dev.yaml"
  value = toset(flatten([
    for eni_id, eni in data.aws_network_interface.nlb_eni_details : [
      eni.private_ip
    ]
  ]))
}

output "vpc_link_id" {
  description = "VPC Link ID connecting API Gateway to internal NLB"
  value       = aws_api_gateway_vpc_link.api_gateway_vpc_link.id
}

output "internal_nlb_arn" {
  description = "ARN of the internal NLB used by VPC Link"
  value       = data.aws_lb.ingress_internal_non_prod_nlb.arn
}

output "internal_nlb_dns_name" {
  description = "DNS name of the internal NLB"
  value       = data.aws_lb.ingress_internal_non_prod_nlb.dns_name
}

output "allowlist_cidr_blocks" {
  description = "CIDR blocks to add to Ingress Allow List (for use in values-dev.yaml)"
  value = [
    for eni_id, eni in data.aws_network_interface.nlb_eni_details : "${eni.private_ip}/32"
  ]
}

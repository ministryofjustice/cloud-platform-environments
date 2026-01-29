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
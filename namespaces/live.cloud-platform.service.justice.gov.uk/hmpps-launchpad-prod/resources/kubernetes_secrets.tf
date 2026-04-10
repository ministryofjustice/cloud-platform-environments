resource "kubernetes_secret" "api_gateway_api_keys" {
  for_each = aws_api_gateway_api_key.clients

  metadata {
    name      = "api-gateway-api-key-${each.key}"
    namespace = var.namespace
  }

  data = {
    api_key_id = aws_api_gateway_api_key.clients[each.key].id
    api_key    = aws_api_gateway_api_key.clients[each.key].value
  }
  type = "Opaque"
}

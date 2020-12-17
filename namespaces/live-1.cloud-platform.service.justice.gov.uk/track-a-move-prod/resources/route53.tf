data "kubernetes_secret" "zone_id" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.base_domain_route53_namespace
  }
}

# Example DNS record using Route53.
# Route53 is not specifically required; any DNS host can be used.
# resource "aws_route53_record" "data" {
#   name    = aws_api_gateway_domain_name.apigw_fqdn.domain_name
#   type    = "A"
#   zone_id = data.kubernetes_secret.zone_id.data["zone_id"]
#
#   alias {
#     evaluate_target_health = true
#     name                   = aws_api_gateway_domain_name.apigw_fqdn.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.apigw_fqdn.regional_zone_id
#   }
# }

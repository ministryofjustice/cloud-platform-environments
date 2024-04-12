resource "aws_route53_zone" "dev_intranet_route53_zone" {
  name = var.base_domain

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "aws_route53_record" "cloudfront_aws_route53_record" {
  name    = var.cloudfront_alias
  zone_id = aws_route53_zone.dev_intranet_route53_zone.zone_id
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.dev_intranet_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.dev_intranet_route53_zone.name_servers)
  }
}
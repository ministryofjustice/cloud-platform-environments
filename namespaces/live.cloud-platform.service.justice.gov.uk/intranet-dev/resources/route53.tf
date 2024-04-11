resource "aws_route53_zone" "cloudfront_route53_zone" {
  name = var.cloudfront_alias

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
  zone_id = aws_route53_zone.cloudfront_route53_zone.zone_id
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

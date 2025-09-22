resource "aws_route53_zone" "websitebuilder__dev_route53_zone" {
  name = "dev.websitebuilder.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "websitebuilder_route53_zone" {
  metadata {
    name      = "websitebuilder-dev-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.websitebuilder__dev_route53_zone.zone_id
  }
}


# Create an A record in the hosted zone for the CloudFront alias.
# Note, the zone_id parameter is set to the zone_id from the hale-platform-prod kubernetes secret.
# And the alias.zone_id parameter is set to the CloudFront hosted zone id.


resource "aws_route53_record" "data" {
  zone_id = aws_route53_zone.websitebuilder__dev_route53_zone.zone_id
  name    = var.cloudfront_alias
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
  }
}

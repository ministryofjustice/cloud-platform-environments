resource "aws_route53_zone" "websitebuilder_staging_route53_zone" {
  name = "staging.websitebuilder.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

data "kubernetes_secret" "route53_zone_output" {
  metadata {
    name      = "websitebuilder-route53-zone-output"
    namespace = "hale-platform-prod"
  }
}

# Delegate staging. to the child zone's NS set
resource "aws_route53_record" "delegate_staging_to_child" {
  zone_id = data.kubernetes_secret.route53_zone_output.data["zone_id"]
  name    = "staging"  # or "staging.websitebuilder.service.justice.gov.uk."
  type    = "NS"
  ttl     = 172800

  records = aws_route53_zone.websitebuilder_staging_route53_zone.name_servers
}

resource "kubernetes_secret" "websitebuilder_route53_zone" {
  metadata {
    name      = "websitebuilder-staging-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.websitebuilder_staging_route53_zone.zone_id
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

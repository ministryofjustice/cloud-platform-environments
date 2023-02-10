resource "aws_route53_zone" "sjpr_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner    
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "sjpr_route53_zone_sec" {
  metadata {
    name      = "sjpr-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id   = aws_route53_zone.sjpr_route53_zone.zone_id
  }
}

resource "aws_route53_record" "add_cname_email" {
  name    = "sjpr-prod.apps.live.cloud-platform.service.justice.gov.uk"
  zone_id = aws_route53_zone.example_team_route53_zone.zone_id
  type    = "CNAME"
  records = ["social-justice-problems.service.justice.gov.uk"]
  ttl     = "300"
}

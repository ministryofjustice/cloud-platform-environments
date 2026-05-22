resource "aws_route53_zone" "prod_reuselibrary_team_route53_zone" {
  name = "reuselibrary.service.justice.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.prod_reuselibrary_team_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.prod_reuselibrary_team_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "delegate_dev" {
  zone_id = aws_route53_zone.prod_reuselibrary_team_route53_zone.zone_id
  name    = "dev.reuselibrary.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300

  records = ["reuse-library-dev.apps.live.cloud-platform.service.justice.gov.uk"]
}

resource "aws_route53_record" "delegate_preprod" {
  zone_id = aws_route53_zone.prod_reuselibrary_team_route53_zone.zone_id
  name    = "preprod.reuselibrary.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = 300

  records = ["reuse-library-preprod.apps.live.cloud-platform.service.justice.gov.uk"]
}

resource "aws_route53_zone" "cla_frontend_route53_zone" {
  name = "cases.civillegaladvice.service.gov.uk"

  tags = {
    team_name              = var.team_name
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "cla_frontend_route53_zone_sec" {
  metadata {
    name      = "cla-frontend-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.cla_frontend_route53_zone.zone_id
  }
}

resource "aws_route53_record" "add_a_record" {
  name    = "."
  zone_id = aws_route53_zone.cla_frontend_route53_zone.zone_id
  type    = "CNAME"
  records = ["dualstack.cla-front-elbprodf-1o815cnz2w3lh-1554019512.eu-west-1.elb.amazonaws.com."]
}

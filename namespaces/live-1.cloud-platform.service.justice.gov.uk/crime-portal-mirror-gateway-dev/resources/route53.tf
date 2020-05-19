resource "aws_route53_zone" "example_team_route53_zone" {
  name = var.zone-name

  tags = {
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "example_route53_zone_sec" {
  metadata {
    name      = "example-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.example_team_route53_zone.zone_id
  }
}

resource "aws_route53_record" "add_cname_email" {
  name    = var.zone-name
  zone_id = aws_route53_zone.example_team_route53_zone.zone_id
  type    = "CNAME"
  records = ["test.org"]
  ttl     = "300"
}

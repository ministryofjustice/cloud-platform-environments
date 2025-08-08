resource "aws_route53_zone" "laa_sign_in_dev" {
  name = "dev.laa-sign-in.external-identity.service.justice.gov.uk"

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

resource "kubernetes_secret" "laa_sign_in_dev_route53_zone" {
  metadata {
    name      = "laa-sign-in-dev-route53-zone"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.laa_sign_in_dev.zone_id
    nameservers = join("\n", aws_route53_zone.laa_sign_in_dev.name_servers)
  }
}
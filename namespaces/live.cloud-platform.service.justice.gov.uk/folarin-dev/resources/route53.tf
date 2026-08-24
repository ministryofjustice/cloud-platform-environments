resource "aws_route53_zone" "folarin_dev_route53_zone" {
  name = var.domain

  tags = {
    team_name              = var.team_name
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.owner
    infrastructure_support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "folarin_dev_route53_zone_sec" {
  metadata {
    name      = "folarin-dev-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id     = aws_route53_zone.folarin_dev_route53_zone.zone_id
    nameservers = join("\n", aws_route53_zone.folarin_dev_route53_zone.name_servers)
  }
}

locals {
  custom_host = "t3"

  octo_nonlive_acme_target = "${local.custom_host}-acme.octo-nonlive.container-platform.service.justice.gov.uk"
  octo_nonlive_nlb         = "octo-nonlive-envoy-default-7f403de9005876a3.elb.eu-west-2.amazonaws.com"
}

# ACME DNS-01 delegation: cert-manager (octo-nonlive) follows this CNAME and writes the
# challenge TXT at the target, which sits in a zone its Pod Identity IAM can write.
resource "aws_route53_record" "custom_acme_challenge" {
  zone_id = aws_route53_zone.folarin_dev_route53_zone.zone_id
  name    = "_acme-challenge.${local.custom_host}.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [local.octo_nonlive_acme_target]
}

resource "aws_route53_record" "custom_traffic" {
  zone_id = aws_route53_zone.folarin_dev_route53_zone.zone_id
  name    = "${local.custom_host}.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [local.octo_nonlive_nlb]
}

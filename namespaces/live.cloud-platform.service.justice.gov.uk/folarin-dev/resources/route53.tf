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
  cp3_envoy_nlb    = "cp-0408-1142-envoy-default-dda361e4fd5147fb.elb.eu-west-2.amazonaws.com"
  cp3_acme_zone    = "development.container-platform.service.justice.gov.uk"
  acceptance_hosts = ["t1", "t2"] # t2 is a spare for a clean retry
}

# Traffic -> CP3 Envoy NLB (ExternalDNS cannot manage this zone, so declared here).
resource "aws_route53_record" "acceptance_traffic" {
  for_each = toset(local.acceptance_hosts)

  zone_id = aws_route53_zone.folarin_dev_route53_zone.zone_id
  name    = "${each.key}.${var.domain}"
  type    = "CNAME"
  ttl     = 300
  records = [local.cp3_envoy_nlb]
}

# ACME delegation for cnameStrategy:Follow. Must resolve BEFORE any cert request
# (else cert-manager tries to write TXT here, has no IAM, and burns LE quota).
resource "aws_route53_record" "acceptance_acme_delegation" {
  for_each = toset(local.acceptance_hosts)

  zone_id = aws_route53_zone.folarin_dev_route53_zone.zone_id
  name    = "_acme-challenge.${each.key}.${var.domain}"
  type    = "CNAME"
  ttl     = 60
  records = ["${each.key}-acme-target.${local.cp3_acme_zone}"]
}

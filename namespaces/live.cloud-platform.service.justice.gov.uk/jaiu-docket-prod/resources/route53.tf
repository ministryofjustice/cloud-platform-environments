# Hosted zone for Docket's production domain. The parent zone, service.justice.gov.uk,
# delegates this name here with an NS record (ministryofjustice/dns,
# hostedzones/service.justice.gov.uk.yaml), using the name servers written to the
# secret below. external-dns then publishes the Ingress hosts on this domain, and
# cert-manager can validate certificates for it. Tags come from the provider's
# default_tags in main.tf.
resource "aws_route53_zone" "route53_zone" {
  name = var.domain

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.route53_zone.zone_id
    name_servers = join(",", aws_route53_zone.route53_zone.name_servers)
  }
}

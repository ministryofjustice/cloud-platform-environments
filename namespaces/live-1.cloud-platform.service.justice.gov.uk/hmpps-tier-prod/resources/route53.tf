resource "aws_route53_zone" "hmpps-tier-prod" {
  name = "hmpps-tier.hmpps.service.justice.gov.uk"

  tags = {
    business-unit          = "Manage a Sentence"
    application            = "HMPPS Tier"
    is-production          = "true"
    environment-name       = "prod"
    owner                  = "Dawn Ramshaw"
    infrastructure-support = "hmpps@digital.justice.gov.uk"
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "hmpps-tier_sec" {
  metadata {
    name      = "hmpps-tier-prod-zone-output"
    namespace = "hmpps-tier-prod"
  }

  data = {
    zone_id = aws_route53_zone.hmpps-tier-prod.zone_id
  }
}


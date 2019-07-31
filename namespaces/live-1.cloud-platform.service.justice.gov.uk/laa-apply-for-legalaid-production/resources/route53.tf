resource "aws_route53_zone" "apply_for_legal_aid_route53_zone" {
  name = "apply-for-legal-aid.service.justice.gov.uk"

  tags {
    business-unit          = "laa"
    application            = "laa-apply-for-legal-aid"
    is-production          = "true"
    environment-name       = "production"
    owner                  = "apply-for-legal-aid"
    infrastructure-support = "apply@digtal.justice.gov.uk"
  }
}

resource "kubernetes_secret" "apply_for_legal_aid_route_53_zone_sec" {
  metadata {
    name      = "apply-for-legal-aid-route53-zone-output"
    namespace = "laa-apply-for-legalaid-production"
  }

  data {
    zone_id = "${aws_route53_zone.apply_for_legal_aid_route53_zone.zone_id}"
  }
}

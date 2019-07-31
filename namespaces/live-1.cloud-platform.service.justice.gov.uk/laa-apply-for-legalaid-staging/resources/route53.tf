resource "aws_route53_zone" "apply_for_legal_aid_route53_zone" {
  name = "staging.apply-for-legal-aid.service.justice.gov.uk"

  tags {
    business-unit          = "laa"
    application            = "laa-apply-for-legal-aid"
    is-production          = "false"
    environment-name       = "staging"
    owner                  = "apply-for-legal-aid"
    infrastructure-support = "apply@digtal.justice.gov.uk"
  }
}

resource "kubernetes_secret" "apply_for_legal_aidroute_53_zone_sec" {
  metadata {
    name      = "apply-for-legal-aid-route53-zone-output"
    namespace = "laa-apply-forlegalaid-staging"
  }

  data {
    zone_id   = "${aws_route53_zone.example_team_route53_zone.zone_id}"
  }
}

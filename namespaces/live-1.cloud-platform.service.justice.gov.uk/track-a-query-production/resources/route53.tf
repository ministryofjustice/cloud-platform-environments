################################################################################
# Track a Query (Correspondence Tool Staff)
# Route53 domain zone settings
#################################################################################

resource "aws_route53_zone" "track_a_query_route53_zone" {
  name = "track-a-query.service.justice.gov.uk"

  tags {
    business-unit          = "Central Digital"
    application            = "track-a-query"
    is-production          = "true"
    environment-name       = "production"
    owner                  = "staff-services"
    infrastructure-support = "correspondence-support@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "track_a_query_route53_zone_sec" {
  metadata {
    name      = "track-a-query-route53-zone-output"
    namespace = "track-a-query-production"
  }

  data {
    zone_id = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
  }
}

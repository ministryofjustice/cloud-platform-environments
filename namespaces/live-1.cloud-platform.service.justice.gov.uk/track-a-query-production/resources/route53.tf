################################################################################
# Track a Query (Correspondence Tool Staff)
# Route53 domain zone settings
#################################################################################

resource "aws_route53_zone" "track_a_query_route53_zone" {
  name = var.domain

  tags = {
    business-unit          = "Central Digital"
    application            = "track-a-query"
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = "staff-services"
    infrastructure-support = "correspondence-support@digital.justice.gov.uk"
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "track_a_query_route53_zone_sec" {
  metadata {
    name      = "track-a-query-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.track_a_query_route53_zone.zone_id
    name_servers = join(
      "\n",
      aws_route53_zone.track_a_query_route53_zone.name_servers,
    )
  }
}


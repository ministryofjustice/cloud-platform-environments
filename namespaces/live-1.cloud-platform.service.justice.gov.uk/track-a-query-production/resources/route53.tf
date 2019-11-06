################################################################################
# Track a Query (Correspondence Tool Staff)
# Route53 domain zone settings
#################################################################################

resource "aws_route53_zone" "track_a_query_route53_zone" {
  name = "${var.domain}"

  tags {
    business-unit          = "Central Digital"
    application            = "track-a-query"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "staff-services"
    infrastructure-support = "correspondence-support@digital.justice.gov.uk"
  }
}

resource "kubernetes_secret" "track_a_query_route53_zone_sec" {
  metadata {
    name      = "track-a-query-route53-zone-output"
    namespace = "${var.namespace}"
  }

  data {
    zone_id      = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
    name_servers = "${join("\n", aws_route53_zone.track_a_query_route53_zone.name_servers)}"
  }
}

resource "aws_route53_record" "track_a_query_route53_A_record_production" {
  name    = "track-a-query.service.gov.uk."
  zone_id = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
  type    = "A"

  alias {
    name    = "haproxy-track-a-query-1357848984.eu-west-1.elb.amazonaws.com."
    zone_id = "Z32O12XQLNTSW2"

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "track_a_query_route53_A_record_development" {
  name    = "development.track-a-query.service.gov.uk."
  zone_id = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
  type    = "A"

  alias {
    name    = "haproxy-track-a-query-1357848984.eu-west-1.elb.amazonaws.com."
    zone_id = "Z32O12XQLNTSW2"

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "track_a_query_route53_A_record_staging" {
  name    = "staging.track-a-query.service.gov.uk."
  zone_id = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
  type    = "A"

  alias {
    name    = "haproxy-track-a-query-1357848984.eu-west-1.elb.amazonaws.com."
    zone_id = "Z32O12XQLNTSW2"

    evaluate_target_health = true
  }
}

resource "aws_route53_record" "track_a_query_route53_A_record_demo" {
  name    = "demo.track-a-query.service.gov.uk."
  zone_id = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
  type    = "A"

  alias {
    name    = "haproxy-track-a-query-1357848984.eu-west-1.elb.amazonaws.com."
    zone_id = "Z32O12XQLNTSW2"

    evaluate_target_health = true
  }
}

# QA is a brand new environment that does not exist in Template Deploy
resource "aws_route53_record" "track_a_query_route53_A_record_qa" {
  name    = "qa.track-a-query.service.gov.uk."
  zone_id = "${aws_route53_zone.track_a_query_route53_zone.zone_id}"
  type    = "A"
}

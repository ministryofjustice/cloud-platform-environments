resource "aws_route53_zone" "route53_zone" {
  name = "prisoner-money.service.justice.gov.uk."

  tags {
    application            = "${var.application}"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "${var.team_name}"
    infrastructure-support = "${var.email}"
  }
}

resource "kubernetes_secret" "route53_zone" {
  metadata {
    name      = "route53-zone-output"
    namespace = "${var.namespace}"
  }

  data {
    short_zone_id = "${aws_route53_zone.route53_zone.zone_id}"
  }
}

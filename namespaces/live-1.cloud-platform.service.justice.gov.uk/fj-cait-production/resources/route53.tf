resource "aws_route53_zone" "route53-zone" {
  name = "${var.domain}"

  tags {
    business-unit          = "${var.business-unit}"
    application            = "${var.application}"
    is-production          = "${var.is-production}"
    environment-name       = "${var.environment-name}"
    owner                  = "${var.team_name}"
    infrastructure-support = "${var.infrastructure-support}"
  }
}

resource "kubernetes_secret" "route53-zone" {
  metadata {
    name      = "cait-route53-zone-output"
    namespace = "${var.namespace}"
  }

  data {
    zone_id = "${aws_route53_zone.route53-zone.zone_id}"
  }
}

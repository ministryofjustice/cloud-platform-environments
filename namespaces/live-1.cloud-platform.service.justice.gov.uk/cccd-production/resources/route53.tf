resource "aws_route53_zone" "cccd_route53_zone" {
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

resource "kubernetes_secret" "cccd_route53_zone_sec" {
  metadata {
    name      = "cccd-route53-zone-output"
    namespace = "${var.namespace}"
  }

  data {
    zone_id      = "${aws_route53_zone.cccd_route53_zone.zone_id}"
    name_servers = "${join("\n", aws_route53_zone.cccd_route53_zone.name_servers)}"
  }
}

resource "aws_route53_record" "cccd_route53_A_record_1" {
  name    = "claim-crown-court-defence.service.gov.uk."
  zone_id = "${aws_route53_zone.cccd_route53_zone.zone_id}"
  type    = "A"

  alias {
    name    = "dualstack.advocated-elbgamma-17de5vdfln9zg-1726434105.eu-west-1.elb.amazonaws.com."
    zone_id = "Z32O12XQLNTSW2"

    evaluate_target_health = false
  }
}

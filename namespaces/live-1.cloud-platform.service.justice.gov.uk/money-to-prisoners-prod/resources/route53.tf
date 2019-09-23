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
    name      = "route53-zone"
    namespace = "${var.namespace}"
  }

  data {
    short_zone_id = "${aws_route53_zone.route53_zone.zone_id}"
  }
}

resource "aws_route53_record" "route53_zone_cname_1" {
  name    = "email.prisoner-money.service.justice.gov.uk."
  zone_id = "${aws_route53_zone.route53_zone.zone_id}"
  type    = "CNAME"
  records = ["eu.mailgun.org"]
  ttl     = "300"
}

resource "aws_route53_record" "route53_zone_txt_1" {
  name    = "prisoner-money.service.justice.gov.uk."
  zone_id = "${aws_route53_zone.route53_zone.zone_id}"
  type    = "TXT"
  records = ["v=spf1 include:eu.mailgun.org ~all"]
  ttl     = "300"
}

resource "aws_route53_record" "route53_zone_txt_2" {
  name    = "smtp._domainkey.prisoner-money.service.justice.gov.uk."
  zone_id = "${aws_route53_zone.route53_zone.zone_id}"
  type    = "TXT"
  records = ["k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0rIehv2VfJOHCm7qxuEfTrDuQFftKUF75jmt7I3EgfCDo+Bf1oagrCLGIAdTpwc399kx4GSQ8Fg32tKA2mxR9+xYKTNp1c6yvAyeRUCzmZ6ZKSgA9vOjvbY/NifKVL3+iHQ+tWs7QWGa+zoxYd5Bi8uXS++NZdmFFSVRFDNdZxnp5q1A0SLoETjEd+rbS54pRdnyqeEzFY\"\"GUIBuNW18bRewvEQdrDz/vHlsCnlm5CEskO5srgxOd9EaLzT1Za1Db9pT+wiVBIn/d0wyulRDjsQFdMZI0O1il9EMnRpW1kC/ohx9IQmiqbd3+LRolknQzoCbtXyea7nxnKNUkk9BRXQIDAQAB"]
  ttl     = "300"
}

resource "aws_route53_record" "route53_zone_mx" {
  name    = "prisoner-money.service.justice.gov.uk."
  zone_id = "${aws_route53_zone.route53_zone.zone_id}"
  type    = "MX"
  records = ["10 mxa.eu.mailgun.org", "10 mxb.eu.mailgun.org"]
  ttl     = "300"
}

resource "aws_route53_zone" "nationalpreventivemechanism_route53_zone" {
  name = "nationalpreventivemechanism.org.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "nationalpreventivemechanism_route53_zone_sec" {
  metadata {
    name      = "npm-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  }
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_a_record" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "nationalpreventivemechanism.org.uk"
  type    = "A"
  ttl     = "300"

  alias {
    name                   = "dualstack.npm-p-loadb-1jky5ygqqvod0-1464047497.eu-west-2.elb.amazonaws.com."
    zone_id                = ""
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_mx_record_smtp" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "nationalpreventivemechanism.org.uk"
  type    = "MX"
  ttl     = "60"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"]
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_cname_record_acm" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "_681eeea354da442b1c9bfe14add8287d.nationalpreventivemechanism.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_b304459684261d5a62e42d5c693d0b9d.nhqijqilxf.acm-validations.aws."]
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_txt_record_amazonses" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "_amazonses.nationalpreventivemechanism.org.uk"
  type    = "TXT"
  ttl     = "60"
  records = ["E2TgLGMdRe0Mm6FlJHvz1FuDrRTRhlHIZlnRTGJ58iQ="]
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_cname_record_www" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "www.nationalpreventivemechanism.org.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["nationalpreventivemechanism.org.uk"]
}

resource "aws_route53_record" "nationalpreventivemechanism_route53_cname_record_acm" {
  zone_id = aws_route53_zone.nationalpreventivemechanism_route53_zone.zone_id
  name    = "_eed4a6f8ce3ece75879fd1d6f87bc74c.www.nationalpreventivemechanism.org.uk"
  type    = "CNAME"
  ttl     = "60"
  records = ["_68e859f260c60a17875814fdfad3333d.nhqijqilxf.acm-validations.aws."]
}

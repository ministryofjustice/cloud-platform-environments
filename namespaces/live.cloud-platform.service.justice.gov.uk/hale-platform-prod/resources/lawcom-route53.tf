resource "aws_route53_zone" "lawcom_route53_zone" {
  name = "lawcom.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "lawcom_route53_zone_sec" {
  metadata {
    name      = "lawcom-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  }
}

resource "aws_route53_record" "lawcom_route53_a_record" {
  zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  name    = "lawcom.gov.uk"
  type    = "A"

  alias {
    name                   = "dualstack.lawco-loadb-iu5qyqrenlez-1402955435.eu-west-2.elb.amazonaws.com."
    zone_id                = "ZHURV8PSTC4K8"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "lawcom_route53_txt_record_mta_sts" {
  zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  name    = "lawcom.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=spf1 -all"]
}

resource "aws_route53_record" "lawcom_route53_cname_record_acm" {
  zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  name    = "_3ff0388722f1072163fc4edb36cb4fec.lawcom.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_ce5444e37666bfe61cfea76e99e67b37.jhztdrwbnw.acm-validations.aws."]
}

resource "aws_route53_record" "lawcom_route53_txt_record_mta_dmarc2" {
  zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  name    = "_dmarc.lawcom.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc-rua@dmarc.service.gov.uk;"]
}

resource "aws_route53_record" "lawcom_route53_cname_record_acm2" {
  zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  name    = "www.lawcom.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["lawcom.gov.uk"]
}

resource "aws_route53_record" "lawcom_route53_cname_record_www_acm" {
  zone_id = aws_route53_zone.lawcom_route53_zone.zone_id
  name    = "_769650e3afe5cd94b01ffd4bd22fe783.www.lawcom.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_9161035e137135a2529c4ea8caf881f4.jhztdrwbnw.acm-validations.aws."]
}

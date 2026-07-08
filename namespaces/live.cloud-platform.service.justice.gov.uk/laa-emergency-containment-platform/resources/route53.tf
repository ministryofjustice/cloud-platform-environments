data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name == "live" ? "live-1" : var.vpc_name]
  }
}

resource "aws_route53_zone" "aws-prd-legalservices-gov-uk" {
  name     = "aws.prd.legalservices.gov.uk"
  vpc {
    vpc_id = data.aws_vpc.selected.id
  }
}

resource "aws_route53_record" "cwa-prod-db" {
  depends_on = [aws_route53_zone.aws-prd-legalservices-gov-uk]
  zone_id = aws_route53_zone.aws-prd-legalservices-gov-uk.zone_id
  name    = "cwa-prod-db"
  type    = "A"

  alias {
    name                   = "cwa-production-db-nlb-blue-green-6a4d60ef7d3e7b0b.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cwa-prod-db1" {
  depends_on = [aws_route53_zone.aws-prd-legalservices-gov-uk]
  zone_id = aws_route53_zone.aws-prd-legalservices-gov-uk.zone_id
  name    = "cwa-prod-db1"
  type    = "A"

  alias {
    name                   = "cwa-production-database-nlb-12d44851fda0f196.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cwa-prod-db3" {
  depends_on = [aws_route53_zone.aws-prd-legalservices-gov-uk]
  zone_id = aws_route53_zone.aws-prd-legalservices-gov-uk.zone_id
  name    = "cwa-prod-db3"
  type    = "A"

  alias {
    name                   = "cwa-production-db-nlb-green-68322e6a90023a4a.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cwa-prod-db2" {
  depends_on = [aws_route53_zone.aws-prd-legalservices-gov-uk]
  zone_id = aws_route53_zone.aws-prd-legalservices-gov-uk.zone_id
  name    = "cwa-prod-db2"
  type    = "A"

  alias {
    name                   = "cwa-production-db-nlb-safe2-54d001c6914e7379.elb.eu-west-2.amazonaws.com"
    zone_id                = "ZD4D7Y8KGAS4G"
    evaluate_target_health = false
  }
}
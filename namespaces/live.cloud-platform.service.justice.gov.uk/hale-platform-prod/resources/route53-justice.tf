resource "aws_route53_zone" "justice_route53_zone" {
  name = "www.justice.gov.uk"

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "aws_route53_record" "justice_mx" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "www.justice.gov.uk."
  type    = "MX"
  ttl     = 1800
  records = [
    "0 ."
  ]
}

resource "aws_route53_record" "justice_spf" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 -all"
  ]
}

resource "aws_route53_record" "justice_dmarc" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "_dmarc.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk;"
  ]
}

resource "aws_route53_record" "justice_domain_key" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "*._domainkey.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DKIM1; p="
  ]
}

resource "aws_route53_record" "justice_github_challenge_moj" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "_github-challenge-ministryofjustice.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "80b1cb80e6"
  ]
}

resource "aws_route53_record" "justice_github_challenge_moj_as" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "_github-challenge-moj-analytical-services.www.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "a75165038c"
  ]
}

resource "aws_route53_record" "justice_github_pages_cname" {
  zone_id = aws_route53_zone.justice_route53_zone.zone_id
  name    = "howto-admin.www.justice.gov.uk."
  type    = "CNAME"
  ttl     = "300"
  records = ["ministryofjustice.github.io"]
}

resource "kubernetes_secret" "justice_route53_zone" {
  metadata {
    name      = "justice-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.justice_route53_zone.zone_id
    name_servers = join("\n", aws_route53_zone.justice_route53_zone.name_servers)
  }
}

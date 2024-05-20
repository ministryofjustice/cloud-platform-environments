resource "aws_route53_zone" "observability_platform_service_justice_gov_uk" {
  name = "observability-platform.service.justice.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "aws_route53_record" "github_pages_verification" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "_github-pages-challenge-ministryofjustice.observability-platform.service.justice.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["87d36fcc49f1fb1ff0a853223ed685"]
}

resource "aws_route53_record" "github_pages" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "observability-platform.service.justice.gov.uk"
  type    = "A"
  ttl     = "300"
  records = ["185.199.108.153", "185.199.109.153", "185.199.110.153", "185.199.111.153"]
}

resource "aws_route53_record" "github_pages_user_guide" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "user-guide.observability-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["ministryofjustice.github.io"]
}

resource "aws_route53_record" "pagerduty_status_page_mail_cname" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "em3198.status.observability-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["u31181182.wl183.sendgrid.net"]
}

resource "aws_route53_record" "pagerduty_status_page_dkim1" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "pdt._domainkey.status.observability-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["pdt.domainkey.u31181182.wl183.sendgrid.net"]
}

resource "aws_route53_record" "pagerduty_status_page_dkim2" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "pdt2._domainkey.status.observability-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["pdt2.domainkey.u31181182.wl183.sendgrid.net"]
}

resource "aws_route53_record" "pagerduty_status_page_tls_certificate" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "_7b1f5f499647d5625e8166e2422c72c6.status.observability-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["_8f93439130be05bb1bb1561c7859212d.mhbtsbpdnt.acm-validations.aws"]
}

resource "aws_route53_record" "pagerduty_status_page_http_traffic" {
  zone_id = aws_route53_zone.observability_platform_service_justice_gov_uk.zone_id
  name    = "status.observability-platform.service.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"
  records = ["cd-b65eda1882c1a51ed8b07272c09d3795.hosted-status.pagerduty.com"]
}

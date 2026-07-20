resource "aws_route53_zone" "jcio_route53_zone" {
  name = "complaints.judicialconduct.gov.uk"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "jcio_route53_zone_sec" {
  metadata {
    name      = "jcio-route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.jcio_route53_zone.zone_id
    nameservers = join(",", aws_route53_zone.jcio_route53_zone.name_servers)
  }
}

resource "aws_route53_record" "jcio_route53_mx_record" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "complaints.judicialconduct.gov.uk"
  type    = "MX"
  ttl     = "600"
  records = ["0 complaints-judicialconduct-gov-uk.mail.protection.outlook.com"]
}

resource "aws_route53_record" "jcio_route53_cname_record_enterpriseenrollment" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "enterpriseenrollment.complaints.judicialconduct.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseenrollment.manage.microsoft.com"]
}

resource "aws_route53_record" "jcio_route53_cname_record_enterpriseregistration" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "enterpriseregistration.complaints.judicialconduct.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["enterpriseregistration.windows.net"]
}

resource "aws_route53_record" "jcio_route53_cname_record_selector1" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "selector1._domainkey.complaints.judicialconduct.gov.uk"
  type    = "CNAME"
  ttl     = "600"
  records = ["selector1-complaints-judicialconduct-gov-uk._domainkey.jcio.onmicrosoft.com"]
}

resource "aws_route53_record" "jcio_route53_cname_record_selector2" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "selector2._domainkey.complaints.judicialconduct.gov.uk"
  type    = "CNAME"
  ttl     = "600"
  records = ["selector2-complaints-judicialconduct-gov-uk._domainkey.jcio.onmicrosoft.com"]
}

resource "aws_route53_record" "jcio_route53_cname_record_autodiscover" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "autodiscover.complaints.judicialconduct.gov.uk"
  type    = "CNAME"
  ttl     = "3600"
  records = ["autodiscover.outlook.com"]
}

resource "aws_route53_record" "jcio_route53_txt_record_main" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "complaints.judicialconduct.gov.uk"
  type    = "TXT"
  ttl     = "600"
  records = ["MS=ms98712360", "v=spf1 include:spf.protection.outlook.com -all"]
}

resource "aws_route53_record" "jcio_route53_txt_record_asvdns" {
  zone_id = aws_route53_zone.jcio_route53_zone.zone_id
  name    = "_asvdns-6d4e5f33-aec8-499f-a30d-9de3ccfc3ae9.complaints.judicialconduct.gov.uk"
  type    = "TXT"
  ttl     = "300"
  records = ["asvdns_0f1daad9-73c3-45b9-a1b0-4f6aec84f081"]
}
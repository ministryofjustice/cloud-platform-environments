# forcing a recheck
resource "aws_route53_zone" "intranet_justice_gov_uk_zone" {
  name = "intranet.justice.gov.uk"

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

resource "aws_route53_record" "mx" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "intranet.justice.gov.uk."
  type    = "MX"
  ttl     = 1800
  records = [
    "0 ."
  ]
}

resource "aws_route53_record" "spf" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "intranet.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=spf1 -all"
  ]
}

resource "aws_route53_record" "dmarc" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "_dmarc.intranet.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DMARC1;p=reject;sp=reject;rua=mailto:dmarc-rua@dmarc.service.gov.uk;"
  ]
}

resource "aws_route53_record" "domain_key" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = "*._domainkey.intranet.justice.gov.uk."
  type    = "TXT"
  ttl     = 300
  records = [
    "v=DKIM1; p="
  ]
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
    name_servers = join("\n", aws_route53_zone.intranet_justice_gov_uk_zone.name_servers)
  }
}

# Create an A record in the hosted zone for the CloudFront alias.
# Note, the zone_id parameter is set to the zone_id from the intranet-production kubernetes secret.
# And the alias.zone_id parameter is set to the CloudFront hosted zone id.
resource "aws_route53_record" "data" {
  zone_id = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name    = var.cloudfront_alias
  type    = "A"

  alias {
    evaluate_target_health = false
    name                   = module.cloudfront.cloudfront_url
    zone_id                = module.cloudfront.cloudfront_hosted_zone_id
  }
}

# In acm.tf, an aws_acm_certificate resource is created for the CloudFront alias.
# As the validation method is set to DNS, a route53 record is created here for the certificate validation.
resource "aws_route53_record" "cert_validations" {
  count           = length(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options)
  zone_id         = aws_route53_zone.intranet_justice_gov_uk_zone.zone_id
  name            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_name, count.index)
  type            = element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_type, count.index)
  records         = [element(aws_acm_certificate.cloudfront_alias_cert.domain_validation_options[*].resource_record_value, count.index)]
  ttl             = 60
  allow_overwrite = true
}

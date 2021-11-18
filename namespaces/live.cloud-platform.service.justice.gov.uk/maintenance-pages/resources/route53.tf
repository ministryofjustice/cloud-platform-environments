resource "aws_route53_zone" "legacy" {
  count = length(var.domains)

  name = var.domains[count.index]

  tags = {
    business-unit          = "webops"
    application            = "maintenance-pages"
    is-production          = "true"
    environment-name       = "production"
    owner                  = "webops"
    infrastructure-support = "platforms@digital.service.justice.gov.uk"
  }
}

# Temp move over civil-eligibility-calculator.justice.gov.uk records ahead of decom

resource "aws_route53_zone" "decom" {

  name = "civil-eligibility-calculator.justice.gov.uk"

  tags = {
    business-unit          = "webops"
    application            = "maintenance-pages"
    is-production          = "true"
    environment-name       = "production"
    owner                  = "webops"
    infrastructure-support = "platforms@digital.service.justice.gov.uk"
  }
}

resource "aws_route53_record" "a" {
  zone_id = aws_route53_zone.decom.zone_id
  name    = "civil-eligibility-calculator.justice.gov.uk"
  type    = "A"

  alias {
    name                   = "dualstack.civileligibilitycalculatorprod-1846998240.eu-west-1.elb.amazonaws.com"
    zone_id                = "aws_route53_zone.decom.zone_id"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cacm1" {
  zone_id = aws_route53_zone.decom.zone_id
  name    = "_ab41e8f5c775aeb6206c29b49479f93a.civil-eligibility-calculator.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"

  records = ["_777ac8c816e5ac5599bf2a650e62a46f.acm-validations.aws"]
}

resource "aws_route53_record" "cacm2" {
  zone_id = aws_route53_zone.decom.zone_id
  name    = "_13d09d497b37e93ac55188334b2c466b.www.civil-eligibility-calculator.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"

  records = ["_5681a198b9b9349021a6929d14afeb0e.acm-validations.aws"]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.decom.zone_id
  name    = "www.civil-eligibility-calculator.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"

  records = ["civil-eligibility-calculator.justice.gov.uk"]
}

resource "aws_route53_record" "www2" {
  zone_id = aws_route53_zone.decom.zone_id
  name    = "eligibilitycalculator.justice.gov.uk"
  type    = "CNAME"
  ttl     = "300"

  records = ["civil-eligibility-calculator.justice.gov.uk"]
}

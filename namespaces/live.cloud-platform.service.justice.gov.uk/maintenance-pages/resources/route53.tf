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

# ---------------------------------------------------------
# Start of Civil Eligibility Calculator
# ---------------------------------------------------------
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

# ---------------------------------------------------------
# End of Civil Eligibility Calculator
# ---------------------------------------------------------
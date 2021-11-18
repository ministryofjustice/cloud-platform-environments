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

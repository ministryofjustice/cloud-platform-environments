# resource "aws_route53_zone" "legacy" {
#   count = length(var.domains)

#   name = var.domains[count.index]

#   tags = {
#     business-unit          = "webops"
#     application            = "maintenance-pages"
#     is-production          = "true"
#     environment-name       = "production"
#     owner                  = "webops"
#     infrastructure-support = "platforms@digital.service.justice.gov.uk"
#   }
# }

resource "aws_route53_zone" "legacy" {

  name = "nomisqc.justice.gov.uk"

  tags = {
    business-unit          = "webops"
    application            = "maintenance-pages"
    is-production          = "true"
    environment-name       = "production"
    owner                  = "webops"
    infrastructure-support = "platforms@digital.service.justice.gov.uk"
  }
}

resource "kubernetes_secret" "route53_zone_sec" {
  metadata {
    name      = "route53-zone-output"
    namespace = var.namespace
  }

  data = {
    zone_id = aws_route53_zone.legacy.zone_id
  }
}
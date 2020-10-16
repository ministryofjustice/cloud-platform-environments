resource "aws_route53_zone" "probation" {
  name = "probation.service.justice.gov.uk"

  tags = {
    business-unit          = "Cloud Platform"
    application            = "probation"
    is-production          = "yes"
    environment-name       = "prod"
    owner                  = "cloud platform"
    infrastructure-support = "cloud platform"
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "probation" {
  metadata {
    name      = "probation-zone-output"
    namespace = "probation-prod"
  }

  data = {
    zone_id = aws_route53_zone.probation.zone_id
  }
}


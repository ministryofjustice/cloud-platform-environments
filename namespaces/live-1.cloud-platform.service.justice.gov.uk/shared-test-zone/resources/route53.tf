resource "aws_route53_zone" "shared" {
  name = "test.cloud-platform.service.justice.gov.uk"

  tags = {
    business-unit          = "webops"
    application            = "shared-zone"
    is-production          = "false"
    environment-name       = "dev"
    owner                  = "webops"
    infrastructure-support = "platforms@digital.service.justice.gov.uk"
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "example_route53_zone_sec" {
  metadata {
    name      = "route53"
    namespace = "shared-test-zone"
  }

  data = {
    zone_id = aws_route53_zone.shared.zone_id
  }
}

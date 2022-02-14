resource "aws_route53_zone" "check-my-diary-prod" {
  name = "checkmydiary.service.justice.gov.uk"

  tags = {
    business-unit          = "Check My Diary"
    application            = "Check My Diary"
    is-production          = "true"
    environment-name       = "prod"
    owner                  = "Lauren Darby"
    infrastructure-support = "digital-studio-operations-team@digital.justice.gov.uk"
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "check-my-diary-prod_sec" {
  metadata {
    name      = "check-my-diary-prod-zone-output"
    namespace = "check-my-diary-prod"
  }

  data = {
    zone_id = aws_route53_zone.check-my-diary-prod.zone_id
  }
}


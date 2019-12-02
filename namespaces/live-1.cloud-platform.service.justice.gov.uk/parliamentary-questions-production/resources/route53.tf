
resource "aws_route53_zone" "parliamentary_questions" {
  name = "var.domain"

  tags = {
    business-unit          = var.team_name
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}

resource "kubernetes_secret" "parliamentary_questions_route53" {
  metadata {
    name      = "parliamentary-questions-route53"
    namespace = var.namespace
  }

  data = {
    zone_id      = aws_route53_zone.parliamentary_questions.zone_id
    name_servers = join("\n", aws_route53_zone.parliamentary_questions.name_servers)
  }
}
resource "aws_iam_access_key" "hmpps-domain-events-rp" {
  user = module.hmpps-domain-events.user_name
}

# TODO: Remove me once secret underneath in use
resource "kubernetes_secret" "hmpps-restricted-patients-api-topic" {
  metadata {
    name      = "hmpps-domain-events-topic"
    namespace = "hmpps-restricted-patients-api-dev"
  }

  data = {
    access_key_id     = module.hmpps-domain-events.access_key_id
    secret_access_key = module.hmpps-domain-events.secret_access_key
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}

resource "kubernetes_secret" "hmpps-restricted-patients-api-topic-rp" {
  metadata {
    name      = "hmpps-domain-events-topic-rp"
    namespace = "hmpps-restricted-patients-api-dev"
  }

  data = {
    access_key_id     = aws_iam_access_key.hmpps-domain-events-rp.id
    secret_access_key = aws_iam_access_key.hmpps-domain-events-rp.secret
    topic_arn         = module.hmpps-domain-events.topic_arn
  }
}

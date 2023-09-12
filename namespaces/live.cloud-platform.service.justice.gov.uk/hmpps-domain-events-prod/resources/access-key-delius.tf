resource "aws_iam_user" "delius-domain-event-topic-user" {
  name = "delius-domain-event-topic-user-prod"
  path = "/system/delius-domain-event-topic-user/"
}

resource "aws_iam_access_key" "delius-domain-event-access" {
  user = aws_iam_user.delius-domain-event-topic-user.name
}

resource "aws_iam_user_policy_attachment" "delius-topic-policy" {
  policy_arn = module.hmpps-domain-events.irsa_policy_arn
  user       = aws_iam_user.delius-domain-event-topic-user.name
}

resource "kubernetes_secret" "delius-hmpps-domain-events-topic-credentials" {
  metadata {
    name      = "delius-hmpps-domain-events-topic-credentials"
    namespace = var.namespace
  }
  data = {
    topic_arn         = module.hmpps-domain-events.topic_arn
    access_key_id     = aws_iam_access_key.delius-domain-event-access.id
    secret_access_key = aws_iam_access_key.delius-domain-event-access.secret
  }
}
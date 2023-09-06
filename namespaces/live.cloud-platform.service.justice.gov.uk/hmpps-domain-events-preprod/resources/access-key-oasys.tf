resource "aws_iam_user" "oasys-domain-event-topic-user" {
  name = "oasys-domain-event-topic-user-preprod"
  path = "/system/oasys-domain-event-topic-user/"
}

resource "aws_iam_access_key" "oasys-domain-event-access" {
  user = aws_iam_user.oasys-domain-event-topic-user.name
}

resource "aws_iam_user_policy_attachment" "oasys-topic-policy" {
  policy_arn = module.hmpps-domain-events.irsa_policy_arn
  user       = aws_iam_user.oasys-domain-event-topic-user.name
}

resource "kubernetes_secret" "oasys-hmpps-domain-events-topic-credentials" {
  metadata {
    name      = "oasys-hmpps-domain-events-topic-credentials"
    namespace = var.namespace
  }
  data = {
    topic_arn         = module.hmpps-domain-events.topic_arn
    access_key_id     = aws_iam_access_key.oasys-domain-event-access.id
    secret_access_key = aws_iam_access_key.oasys-domain-event-access.secret
  }
}
###
# Creates an SNS topic for crime matching notifications.
# Creates topic policy that allows only the k8s service account role to publish messages.
###

module "matching_notifications_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "${var.namespace}-matching-notifications"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "matching_notifications_topic" {
  metadata {
    name      = "matching-notifications-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.matching_notifications_topic.topic_arn
    topic_name = module.matching_notifications_topic.topic_name
  }
}

resource "aws_sns_topic_policy" "matching_notifications" {
  arn = module.matching_notifications_topic.topic_arn
  policy = data.aws_iam_policy_document.matching_notifications_topic.json
}

data "aws_iam_policy_document" "matching_notifications_topic" {
  statement {
    sid = "AllowPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]

    resources = [
      module.matching_notifications_topic.topic_arn,
    ]

    principals {
      type = "AWS"
      identifiers = [
        module.irsa.role_arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [
        data.aws_caller_identity.current.account_id,
      ]
    }
  }
}

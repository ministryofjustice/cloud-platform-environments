###
# Creates an SNS topic that SES can publish to.
###

module "email_notifications_topic" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "${var.namespace}-email-notifications"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "email_notifications_topic" {
  metadata {
    name      = "email-notifications-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.email_notifications_topic.topic_arn
    topic_name = module.email_notifications_topic.topic_name
  }
}

resource "aws_sns_topic_policy" "email_notifications" {
  arn = module.email_notifications_topic.topic_arn
  policy = data.aws_iam_policy_document.email_notifications_topic.json
}

data "aws_iam_policy_document" "email_notifications_topic" {
  statement {
    sid = "AllowSESPublish"
    effect = "Allow"
    actions = [
      "sns:Publish"
    ]

    resources = [
      module.email_notifications_topic.topic_arn
    ]

    principals {
      type = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values = [data.aws_caller_identity.current.account_id]
    }
  }
}

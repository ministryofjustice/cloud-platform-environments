module "crime_batch_sns" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "ac-crime-batch"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "crime_batch_sns_topic" {
  metadata {
    name      = "crime-batch-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.crime_batch_sns.topic_arn
    topic_name = module.crime_batch_sns.topic_name
  }
}

resource "aws_sns_topic_subscription" "crime-batch-queue-subscription" {
  topic_arn     = module.crime_batch_sns.topic_arn
  endpoint      = module.crime_batch_sqs.sqs_arn
  protocol      = "sqs"
}

resource "aws_sns_topic_policy" "ses_to_sns_access" {
  arn = module.crime_batch_sns.topic_arn
  policy = data.aws_iam_policy_document.sns_access.json
}

data "aws_iam_policy_document" "sns_access" {
  statement {
    sid = "AllowSESPublish"
    actions = [
      "sns:Publish"
    ]

    resources = [
      module.crime_batch_sns.topic_arn
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
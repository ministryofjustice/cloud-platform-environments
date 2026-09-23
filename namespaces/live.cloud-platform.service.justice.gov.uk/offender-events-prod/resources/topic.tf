module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Confgiuration
  topic_display_name = "offender-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_events" {
  metadata {
    name      = "offender-events-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = module.offender_events.topic_arn
  }
}

module "probation_offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=5.1.2"

  # Configuration
  topic_display_name = "probation-offender-events"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the topic
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

data "aws_caller_identity" "current" {
  provider = aws.london
}

data "aws_iam_policy_document" "offender_events_topic_policy" {
  statement {
    sid    = "AllowTopicPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [module.offender_events.topic_arn]
  }
}

resource "aws_sns_topic_policy" "offender_events_topic_policy" {
  provider = aws.london
  arn      = module.offender_events.topic_arn
  policy   = data.aws_iam_policy_document.offender_events_topic_policy.json
}

data "aws_iam_policy_document" "probation_offender_events_topic_policy" {
  statement {
    sid    = "AllowTopicPublish"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [module.probation_offender_events.topic_arn]
  }
}

resource "aws_sns_topic_policy" "probation_offender_events_topic_policy" {
  provider = aws.london
  arn      = module.probation_offender_events.topic_arn
  policy   = data.aws_iam_policy_document.probation_offender_events_topic_policy.json
}

resource "kubernetes_secret" "offender-events-and-delius-topic-secret" {
  metadata {
    name      = "offender-events-and-delius-topic"
    namespace = "hmpps-probation-integration-services-${var.environment}"
  }
  data = {
    TOPIC_ARN = module.probation_offender_events.topic_arn
  }
}

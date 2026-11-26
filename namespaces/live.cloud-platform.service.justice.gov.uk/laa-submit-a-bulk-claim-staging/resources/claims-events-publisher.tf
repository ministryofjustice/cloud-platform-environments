data "aws_ssm_parameter" "claims_events_topic_arn" {
  name = "/laa-data-claims-api-staging/topic-arn"
}

# The Claims API SNS module names the KMS alias after the SNS topic.
data "aws_kms_alias" "claims_events_topic_key" {
  name = "alias/${split(":", data.aws_ssm_parameter.claims_events_topic_arn.value)[5]}"
}

data "aws_iam_policy_document" "claims_events_publisher" {
  statement {
    sid       = "PublishClaimsEvents"
    actions   = ["sns:Publish"]
    resources = [data.aws_ssm_parameter.claims_events_topic_arn.value]
  }

  statement {
    sid       = "UseClaimsEventsTopicKey"
    actions   = ["kms:GenerateDataKey*", "kms:Decrypt"]
    resources = [data.aws_kms_alias.claims_events_topic_key.target_key_arn]
  }
}

resource "aws_iam_policy" "claims_events_publisher" {
  name        = "${var.namespace}-claims-events-publisher"
  description = "Publish reminders to the staging Claims Events SNS topic"
  policy      = data.aws_iam_policy_document.claims_events_publisher.json
}

module "claims_events_publisher_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "irsa-sns-${var.namespace}"
  namespace            = var.namespace

  role_policy_arns = {
    sns = aws_iam_policy.claims_events_publisher.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "claims_events_sns_topic" {
  metadata {
    name      = "claims-events-sns-topic"
    namespace = var.namespace
  }

  data = {
    topic_arn = data.aws_ssm_parameter.claims_events_topic_arn.value
  }
}

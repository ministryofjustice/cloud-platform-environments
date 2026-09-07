# Add outputs that need to be consumed in other namespaces here.

locals {
  sqs_queue_arns = {
    (module.cvl_domain_events_queue.sqs_name)                   = module.cvl_domain_events_queue.sqs_arn,
    (module.cvl_domain_events_dead_letter_queue.sqs_name)       = module.cvl_domain_events_dead_letter_queue.sqs_arn,
    (module.cvl_test1_domain_events_queue.sqs_name)             = module.cvl_test1_domain_events_queue.sqs_arn,
    (module.cvl_test1_domain_events_dead_letter_queue.sqs_name) = module.cvl_test1_domain_events_dead_letter_queue.sqs_arn,
    (module.cvl_test2_domain_events_queue.sqs_name)             = module.cvl_test2_domain_events_queue.sqs_arn,
    (module.cvl_test2_domain_events_dead_letter_queue.sqs_name) = module.cvl_test2_domain_events_dead_letter_queue.sqs_arn,
    (module.curious_queue.sqs_name)                             = module.curious_queue.sqs_arn,
    (module.curious_dead_letter_queue.sqs_name)                 = module.curious_dead_letter_queue.sqs_arn,
    (module.activities_domain_events_queue.sqs_name)            = module.activities_domain_events_queue.sqs_arn,
    (module.activities_domain_events_dead_letter_queue.sqs_name)= module.activities_domain_events_dead_letter_queue.sqs_arn,
    (module.hdc_domain_events_queue.sqs_name)                   = module.hdc_domain_events_queue.sqs_arn,
    (module.hdc_domain_events_dead_letter_queue.sqs_name)       = module.hdc_domain_events_dead_letter_queue.sqs_arn,
    (module.in_cell_queue.sqs_name)                             = module.in_cell_queue.sqs_arn,
    (module.in_cell_dead_letter_queue.sqs_name)                 = module.in_cell_dead_letter_queue.sqs_arn
  }

  sns_publish_irsa_policy_arn = aws_iam_policy.sns_topic_irsa_publish.arn

  sqs_irsa_policies = {
    for queue_name, queue_arn in local.sqs_queue_arns : queue_name => aws_iam_policy.sqs_irsa_policy[queue_name].arn
  }

  sns_irsa_policies = {
    (module.hmpps-domain-events.topic_name) = local.sns_publish_irsa_policy_arn
  }
}

data "aws_iam_policy_document" "sqs_irsa_policy" {
  for_each = local.sqs_queue_arns

  statement {
    sid    = "AllowQueueReadWrite${replace(each.key, "-", "_")}"
    effect = "Allow"
    actions = [
      "sqs:GetQueueUrl",
      "sqs:GetQueueAttributes",
      "sqs:SendMessage",
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:PurgeQueue",
      "sqs:StartMessageMoveTask"
    ]
    resources = [each.value]
  }
}

data "aws_iam_policy_document" "sns_topic_irsa_publish" {
  version = "2012-10-17"

  statement {
    sid    = "AllowPublishToHMPPSDomainEventsTopic"
    effect = "Allow"
    actions = [
      "sns:Publish",
      "sns:GetTopicAttributes",
    ]
    resources = [module.hmpps-domain-events.topic_arn]
  }
}

resource "aws_iam_policy" "sqs_irsa_policy" {
  for_each = local.sqs_queue_arns

  name = "${var.namespace}-${replace(each.key, "/[^a-zA-Z0-9-]/", "-")}-queue"
  path = "/cloud-platform/sqs/"
  policy = data.aws_iam_policy_document.sqs_irsa_policy[each.key].json

  tags = local.tags
}

resource "aws_iam_policy" "sns_topic_irsa_publish" {
  name = "${var.namespace}-publish-hmpps-domain-events-topic"
  path = "/cloud-platform/sns/"
  policy = data.aws_iam_policy_document.sns_topic_irsa_publish.json

  tags = local.tags
}

resource "aws_ssm_parameter" "tf-outputs-sqs-irsa-policies" {
  for_each = local.sqs_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}

resource "aws_ssm_parameter" "tf-outputs-sns-irsa-policies" {
  for_each = local.sns_irsa_policies
  type     = "String"
  name     = "/${var.namespace}/sns/${each.key}/irsa-policy-arn"
  value    = each.value
  tags     = local.tags
}

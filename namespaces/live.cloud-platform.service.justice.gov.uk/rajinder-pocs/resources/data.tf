/* --SQS Access Control--
The two data sources below control access to SQS by looking
up the value in the "application" tag for a specific namespace.
This seems reliable we I can assume it's fairly unique and
application specific */

data "aws_iam_roles" "sqs_subscriber_applications" {
  filter {
    name   = "tag:application"
    values = concat([var.application], var.sqs_queue_subscriber_applications)
  }
}

data "aws_iam_policy_document" "sqs_send_only" {
  statement {
    sid    = "allow"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:SendMessage"
    ]

    resources = [module.rajinder_poc_sqs_queue.sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = data.aws_iam_roles.sqs_subscriber_applications.arns
    }
  }
}

/* --SQS Access Control--
The two data sources below control access to SQS by looking up the value in the "application" tag
for a specific namespace.
This is not a perfect solution but does solve a dependency problem and prevents needing to store
unpredictable ARNs as a variable application specific */

data "aws_iam_roles" "sqs_subscriber_roles" {
  name_regex = "^cloud-platform-irsa.*" #--All irsa roles in CP. This has a 1000 limit. Might not be viable
}

data "aws_iam_role" "sqs_matching_roles" {
  for_each = toset(local.sqs_matching_role_names)
  name     = each.value
}

#--This policy will be constructed from the data sources above and some local transformations to grant SQS access
data "aws_iam_policy_document" "sqs_send_only" {
  statement {
    sid    = "AllowSend"
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
      values = [
        for role in local.sqs_roles_with_app_tag : role.arn
      ]
    }
  }

  statement {
    sid    = "AllowReadDelete"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl"
    ]

    resources = [module.rajinder_poc_sqs_queue.sqs_arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values = [
        for role in local.sqs_roles_with_app_tag : role.arn
      ]
    }
  }
}

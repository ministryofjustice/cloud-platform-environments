data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "dynamodb_access_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:DescribeTable",
      "dynamodb:Scan"
    ]
    resources = [
      module.dynamodb.table_arn
    ]
  }
}

resource "aws_iam_user_policy" "dynamodb_user_policy" {
  name   = "dynamodb-state-read-write-policy"
  policy = data.aws_iam_policy_document.dynamodb_access_policy.json
  user   = aws_iam_user.s3_user.name
}

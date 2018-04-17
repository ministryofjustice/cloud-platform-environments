provider "aws" {
  region = "eu-west-1"
}

# Remote state store
terraform {
  backend "s3" {
    bucket = "build-notifications-cloud-platforms"
    region = "eu-west-1"
    key    = "terraform.tfstate"
  }
}

# Cloudwatch event creation
resource "aws_cloudwatch_event_rule" "codebuild_watcher_rule" {
  name        = "cp-build-notifications"
  description = "Capture CodeBuild events and trigger a Lambda which pushes to Slack"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codebuild"
  ],
  "detail-type": [
    "CodeBuild Build State Change"
  ],
  "detail": {
    "build-status": [
      "FAILED",
      "SUCCEEDED",
      "IN_PROGRESS",
      "STOPPED"
    ]
  }
}
PATTERN
}

# Lambda execution IAM policy
resource "aws_iam_role" "cp_build_LambdaExecution" {
  name = "cp-build-notification-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "cp_build_LambdaPolicy" {
  name = "cp-build-notification-policy"
  role = "${aws_iam_role.cp_build_LambdaExecution.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Resource": [
        "*"
      ],
      "Effect": "Allow"
    }
  ]
}
POLICY
}

# Lambda invocation permissions
resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.notify_slack.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.codebuild_watcher_rule.arn}"
}

# Lambda function
resource "aws_lambda_function" "notify_slack" {
  filename      = "functions/notify_slack.zip"
  function_name = "cloud-platforms-codebuild-notifier"
  description   = "CodeBuild success failure notification to Slack"
  role          = "${aws_iam_role.cp_build_LambdaExecution.arn}"
  handler       = "notify_slack.handler"
  runtime       = "nodejs8.10"
  timeout       = 30

  environment {
    variables = {
      SLACK_HOOK_URL = "${var.slack_webhook_url}"
    }
  }
}

# Cloudwatch event execution
resource "aws_cloudwatch_event_target" "codebuild_watcher_target" {
  rule = "${aws_cloudwatch_event_rule.codebuild_watcher_rule.name}"
  arn  = "${aws_lambda_function.notify_slack.arn}"
}

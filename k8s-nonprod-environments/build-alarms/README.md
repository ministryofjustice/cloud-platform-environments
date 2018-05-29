# # Codebuild-slack notification module

This module contains a CloudWatch event rule which captures Codebuild events and triggers a lambda function which notifies your slack channel on the build success or failure using [incoming webhooks API](https://api.slack.com/incoming-webhooks).

Start by setting up an [incoming webhook integration](https://my.slack.com/services/new/incoming-webhook/) in your Slack workspace.

## CloudWatch Events
This resource in terraform creates a CloudWatch event rule which will capture the status ["Success" or "Failure"] of your CodeBuild once it has completed. The status of your build will then trigger the lambda.

```hcl
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

```

## Lambda

This resource creates the lambda function. Once CloudWatch events triggers the lambda, the lambda will send a notification of your codebuild to your slack channel.

```hcl

resource "aws_lambda_function" "notify_slack" {
  filename      = "functions/notify_slack.zip"
  function_name = "cloud-platforms-codebuild-notifier"
  description   = "CodeBuild success failure notification to Slack"
  role          = "${aws_iam_role.cp_build_LambdaExecution.arn}"
  handler       = "notify_slack.handler"
  runtime       = "nodejs8.10"
  timeout       = 30


```


## Usage

Git clone repo, change current directory to k8s-nonprod-environments/build-alarms

```bash
$ git-crypt unlock

$ terraform plan

# run terraform apply to apply changes.

terraform apply

```



locals {
  github_oidc_provider = "token.actions.githubusercontent.com"
  github_repositories  = toset(var.github_actions_repositories)
  github_environments  = toset(var.github_actions_environments)

  github_repo_envs = {
    for pair in setproduct(local.github_repositories, local.github_environments) :
    "${pair[0]}.${pair[1]}" => {
      repository  = pair[0]
      environment = pair[1]
    }
  }
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.github_oidc_provider}"
}

data "aws_iam_policy_document" "github_sns_publish_assume_role" {
  version = "2012-10-17"

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = (length(local.github_repositories) == 1) ? "StringLike" : "ForAnyValue:StringLike"
      variable = "${local.github_oidc_provider}:sub"
      values   = formatlist("repo:ministryofjustice/%s:*", local.github_repositories)
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "github_sns_publish" {
  version = "2012-10-17"

  statement {
    sid    = "AllowPublishToWorkflowLogTopic"
    effect = "Allow"
    actions = [
      "sns:Publish",
    ]
    resources = [
      module.log_events_topic.topic_arn,
    ]
  }
}

resource "aws_iam_role" "github_sns_publisher" {
  name               = "${var.namespace}-gha-sns-publisher"
  assume_role_policy = data.aws_iam_policy_document.github_sns_publish_assume_role.json
}

resource "aws_iam_policy" "github_sns_publish" {
  name   = "${var.namespace}-gha-sns-publish"
  policy = data.aws_iam_policy_document.github_sns_publish.json
}

resource "aws_iam_role_policy_attachment" "github_sns_publish" {
  role       = aws_iam_role.github_sns_publisher.name
  policy_arn = aws_iam_policy.github_sns_publish.arn
}

resource "github_actions_secret" "sns_publish_role_to_assume" {
  for_each = (length(var.github_actions_environments) == 0) ? local.github_repositories : []

  repository      = each.value
  secret_name     = "SNS_PUBLISH_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.github_sns_publisher.arn
}

resource "github_actions_variable" "sns_topic_arn" {
  for_each = (length(var.github_actions_environments) == 0) ? local.github_repositories : []

  repository    = each.value
  variable_name = "SNS_TOPIC_ARN"
  value         = module.log_events_topic.topic_arn
}

resource "github_actions_environment_secret" "sns_publish_role_to_assume" {
  for_each = local.github_repo_envs

  repository      = each.value.repository
  environment     = each.value.environment
  secret_name     = "SNS_PUBLISH_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.github_sns_publisher.arn
}

resource "github_actions_environment_variable" "sns_topic_arn" {
  for_each = local.github_repo_envs

  repository    = each.value.repository
  environment   = each.value.environment
  variable_name = "SNS_TOPIC_ARN"
  value         = module.log_events_topic.topic_arn
}

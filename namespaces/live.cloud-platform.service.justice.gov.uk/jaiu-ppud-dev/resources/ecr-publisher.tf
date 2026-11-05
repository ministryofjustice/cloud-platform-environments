data "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "ppud_ecr_publisher_assume_role" {
  statement {
    sid     = "GitHubActionsCloudPlatformDevEnvironment"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:JusticeAIUnit/ppudreplacement:environment:cloud-platform-dev",
        "repo:JusticeAIUnit@215010991/ppudreplacement@1321823112:environment:cloud-platform-dev",
      ]
    }
  }
}

resource "aws_iam_role" "ppud_ecr_publisher" {
  name               = "${var.namespace}-ecr-publisher"
  assume_role_policy = data.aws_iam_policy_document.ppud_ecr_publisher_assume_role.json
}

data "aws_iam_policy_document" "ppud_ecr_publisher" {
  statement {
    sid       = "AuthenticateToEcr"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }

  statement {
    sid    = "PublishOnlyNamespaceImages"
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    resources = [
      module.ppud_frontend_ecr.repo_arn,
      module.ppud_backend_ecr.repo_arn,
    ]
  }
}

resource "aws_iam_policy" "ppud_ecr_publisher" {
  name        = "${var.namespace}-ecr-publisher"
  description = "Publish PPUD dev frontend and backend images only"
  policy      = data.aws_iam_policy_document.ppud_ecr_publisher.json
}

resource "aws_iam_role_policy_attachment" "ppud_ecr_publisher" {
  role       = aws_iam_role.ppud_ecr_publisher.name
  policy_arn = aws_iam_policy.ppud_ecr_publisher.arn
}

output "ppud_ecr_publisher_role_arn" {
  description = "Role ARN for the protected cloud-platform-dev GitHub environment"
  value       = aws_iam_role.ppud_ecr_publisher.arn
}

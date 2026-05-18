# ECR read-only GitHub Actions consumers
#
# - This service owns the ECR repository.
# - GitHub consumer repositories can pull the image.
# - Each consumer gets its own GitHub Actions OIDC IAM role.
# - GitHub Actions secrets/variables are written to the consumer repo.

data "aws_region" "current" {}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

locals {
  github_oidc_issuer = "token.actions.githubusercontent.com"

  ecr_url_parts = split("/", module.ecr_credentials.repo_url)
  ecr_registry  = local.ecr_url_parts[0]
  ecr_repo      = join("/", slice(local.ecr_url_parts, 1, length(local.ecr_url_parts)))

  ecr_readonly_consumer_subjects = {
    for name, consumer in local.ecr_readonly_consumers :
    name => [
      for subject in consumer.subjects :
      "repo:${local.ecr_readonly_github_organisation}/${consumer.repository}:${subject}"
    ]
  }

  ecr_readonly_consumer_variables = merge([
    for name, consumer in local.ecr_readonly_consumers : {
      "${name}.region" = {
        repository = consumer.repository
        name       = "${upper(consumer.prefix)}_ECR_REGION"
        value      = data.aws_region.current.name
      }

      "${name}.repository" = {
        repository = consumer.repository
        name       = "${upper(consumer.prefix)}_ECR_REPOSITORY"
        value      = local.ecr_repo
      }
    }
  ]...)
}

####################################################

# Read-only IAM policy for ECR
####################################################

data "aws_iam_policy_document" "ecr_readonly" {
  statement {
    sid     = "AllowEcrLogin"
    effect  = "Allow"
    actions = ["ecr:GetAuthorizationToken"]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPullFromRepository"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:GetDownloadUrlForLayer",
      "ecr:ListImages"
    ]

    resources = [
      module.ecr_credentials.repo_arn
    ]
  }
}

resource "aws_iam_policy" "ecr_readonly" {
  count = length(local.ecr_readonly_consumers) > 0 ? 1 : 0

  name   = substr("${local.ecr_readonly_name_prefix}-policy", 0, 128)
  policy = data.aws_iam_policy_document.ecr_readonly.json

  tags = merge(local.ecr_readonly_tags, {
    ecr-access-level = "readonly"
  })
}

####################################################

# IAM policy per GitHub Actions consumer
####################################################

data "aws_iam_policy_document" "github_assume_role" {
  for_each = local.ecr_readonly_consumers

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.github_oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "${local.github_oidc_issuer}:sub"
      values   = local.ecr_readonly_consumer_subjects[each.key]
    }
  }
}

####################################################

# IAM role per consumer with consumer policy attachment
####################################################

resource "aws_iam_role" "github_consumer" {
  for_each = local.ecr_readonly_consumers

  name = substr("${local.ecr_readonly_name_prefix}-${each.key}", 0, 64)

  assume_role_policy = data.aws_iam_policy_document.github_assume_role[each.key].json

  tags = merge(local.ecr_readonly_tags, {
    ecr-access-level = "readonly"
    ecr-consumer     = each.key
    github-repo      = "${local.ecr_readonly_github_organisation}/${each.value.repository}"
  })
}

resource "aws_iam_role_policy_attachment" "github_consumer_ecr_readonly" {
  for_each = local.ecr_readonly_consumers

  role       = aws_iam_role.github_consumer[each.key].name
  policy_arn = aws_iam_policy.ecr_readonly[0].arn
}

####################################################

# GitHub Actions values in consumer repos
####################################################

resource "github_actions_secret" "ecr_role_to_assume" {
  for_each = local.ecr_readonly_consumers

  repository      = each.value.repository
  secret_name     = "${upper(each.value.prefix)}_ECR_READONLY_ROLE_TO_ASSUME"
  plaintext_value = aws_iam_role.github_consumer[each.key].arn
}

resource "github_actions_secret" "ecr_registry_url" {
  for_each = local.ecr_readonly_consumers

  repository      = each.value.repository
  secret_name     = "${upper(each.value.prefix)}_ECR_REGISTRY_URL"
  plaintext_value = local.ecr_registry
}

resource "github_actions_variable" "ecr_values" {
  for_each = local.ecr_readonly_consumer_variables

  repository    = each.value.repository
  variable_name = each.value.name
  value         = each.value.value
}
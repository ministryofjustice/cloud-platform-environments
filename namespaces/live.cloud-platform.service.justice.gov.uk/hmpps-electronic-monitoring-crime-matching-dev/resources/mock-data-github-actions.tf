resource "github_repository_environment" "env" {
  repository  = "hmpps-electronic-monitoring-crime-matching"
  environment = var.environment

  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

resource "github_repository_environment_deployment_policy" "env" {
  repository     = github_repository_environment.env.repository
  environment    = github_repository_environment.env.environment
  branch_pattern = "main"
}

data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "github_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
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
        "repo:${var.github_owner}/hmpps-electronic-monitoring-crime-matching:environment:${github_repository_environment.env.environment}"
      ]
    }
  }
}

resource "aws_iam_role" "github_role" {
  name               = "${var.namespace}-synthetic-data-uploader"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
  tags               = local.tags
}

data "aws_iam_policy_document" "synthetic_data_upload" {
  statement {
    sid     = "UploadSyntheticMonitoringData"
    actions = ["s3:PutObject"]

    resources = [
      "${module.data_bucket.bucket_arn}/position/position.csv",
      "${module.data_bucket.bucket_arn}/device_activations/device_activations.csv",
      "${module.data_bucket.bucket_arn}/caseload/caseload.csv",
      "${module.data_bucket.bucket_arn}/orders_activations_positions/orders_activations_positions.csv",
    ]
  }
}

resource "aws_iam_role_policy" "mock_data_upload" {
  name   = "upload-mock-data"
  role   = aws_iam_role.github_role.id
  policy = data.aws_iam_policy_document.synthetic_data_upload.json
}

resource "github_actions_environment_variable" "mock_data_role_arn" {
  repository    = github_repository_environment.env.repository
  environment   = github_repository_environment.env.environment
  variable_name = "MOCK_DATA_ROLE_ARN"
  value         = aws_iam_role.github_role.arn
}

resource "github_actions_environment_variable" "mock_data_bucket" {
  repository    = github_repository_environment.env.repository
  environment   = github_repository_environment.env.environment
  variable_name = "MOCK_DATA_BUCKET"
  value         = module.data_bucket.bucket_name
}
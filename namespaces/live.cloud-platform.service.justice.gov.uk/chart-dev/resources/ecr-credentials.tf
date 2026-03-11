# ECR Credentials for GitHub Actions to push Docker images
module "ecr_credentials" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-ecr-credentials?ref=8.0.0"

  # ECR Repository name
  repo_name = "laa-generic-app"

  # OpenID Connect configuration for GitHub Actions
  oidc_providers      = ["github"]
  github_repositories = ["laa-generic-helm-chart"]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = false
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

# Find the IAM role created by the ECR module
data "aws_iam_roles" "ecr_github_roles" {
  provider   = aws.london
  name_regex = "^cloud-platform-ecr-.*-github$"

  depends_on = [module.ecr_credentials]
}

# Get current AWS account ID for use in resource ARN
data "aws_caller_identity" "current" {
  provider = aws.london
}

resource "aws_iam_role_policy" "ecr_push_policy" {
  provider = aws.london
  name     = "ecr-push-policy"
  role     = tolist(data.aws_iam_roles.ecr_github_roles.names)[0]

  depends_on = [module.ecr_credentials]

  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect" = "Allow"
        "Action" = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken"
        ]
        "Resource" = module.ecr_credentials.repo_arn
      }
    ]
  })
}

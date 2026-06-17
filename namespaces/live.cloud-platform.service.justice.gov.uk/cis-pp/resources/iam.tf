resource "aws_iam_policy" "frontend_s3_deploy" {
  name        = "${var.namespace}-frontend-s3-deploy"
  description = "Allow CI to sync static assets to the ${var.namespace} frontend S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListFrontendBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation",
        ]
        Resource = aws_s3_bucket.frontend.arn
      },
      {
        Sid    = "ManageFrontendObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.frontend.arn}/*"
      },
    ]
  })
}

resource "aws_iam_policy" "frontend_cloudfront_invalidate" {
  name        = "${var.namespace}-frontend-cloudfront-invalidate"
  description = "Allow CI to invalidate the ${var.namespace} CloudFront distribution after deploy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvalidateFrontendDistribution"
        Effect = "Allow"
        Action = [
          "cloudfront:GetDistribution",
          "cloudfront:ListDistributions",
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations",
        ]
        Resource = aws_cloudfront_distribution.frontend.arn
      },
    ]
  })
}

module "github_oidc_iam_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "5.9.2"

  name_prefix = "${var.namespace}-github-oidc"
  path        = "/cloud-platform/"

  subjects = ["ministryofjustice/${var.github_repository}:*"]

  policies = {
    s3         = aws_iam_policy.frontend_s3_deploy.arn
    cloudfront = aws_iam_policy.frontend_cloudfront_invalidate.arn
  }

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "github_oidc_iam_role" {
  metadata {
    name      = "github-oidc-iam-role"
    namespace = var.namespace
  }

  data = {
    role_arn = module.github_oidc_iam_role.arn
  }
}
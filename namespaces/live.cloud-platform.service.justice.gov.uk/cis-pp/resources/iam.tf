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

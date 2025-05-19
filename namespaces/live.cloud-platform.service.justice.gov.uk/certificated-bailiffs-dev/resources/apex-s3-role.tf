resource "aws_iam_role" "rds_s3_integration" {
  name = "rds-s3-integration-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "rds.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}


resource "aws_iam_policy" "rds_s3_access_policy" {
  name        = "rds-s3-access-policy"
  description = "Policy for RDS to access specific S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket"
        ],
        Resource = module.apex-migration-s3.bucket_arn
      },
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        Resource = "${module.apex-migration-s3.bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_s3_attach" {
  role       = aws_iam_role.rds_s3_integration.name
  policy_arn = aws_iam_policy.rds_s3_access_policy.arn
}


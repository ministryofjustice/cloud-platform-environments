resource "aws_iam_role" "apex_rds_s3_role" {
  name = "apex-rds-s3-access-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "rds_s3_policy" {
  name        = "rds-s3-policy"
  description = "Policy to allow RDS to access S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::your-s3-bucket-name",              # Bucket itself
          "arn:aws:s3:::your-s3-bucket-name/*"             # All objects within the bucket
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_s3_role_attachment" {
  policy_arn = aws_iam_policy.rds_s3_policy.arn
  role       = aws_iam_role.rds_s3_role.name
}

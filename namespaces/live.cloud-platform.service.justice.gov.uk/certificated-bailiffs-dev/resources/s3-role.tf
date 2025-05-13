resource "aws_iam_role" "apex_rds_s3_role" {
  name               = "apex-rds-s3-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "rds.amazonaws.com" 
        }
        Action = "sts:AssumeRole" 
      }
    ]
  })
}


resource "aws_iam_role_policy" "apex_rds_s3_policy" {
  name = "apex-rds-s3-policy"
  role = aws_iam_role.apex_rds_s3_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ]
        Resource = [
          "${module.apex_migration_bucket.bucket_arn}",
          "${module.apex_migration_bucket.bucket_arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "rds_s3_role_attachment" {
  policy_arn = aws_iam_policy.rds_s3_policy.arn
  role       = aws_iam_role.apex_rds_s3_role.name
}

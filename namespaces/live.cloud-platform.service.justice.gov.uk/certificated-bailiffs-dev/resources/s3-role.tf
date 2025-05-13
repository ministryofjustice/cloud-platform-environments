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

resource "aws_s3_bucket_policy" "apex_migration_bucket_policy" {
  bucket = module.apex_migration_bucket.bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = [
            aws_iam_role.apex_rds_s3_role.arn
          ]
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.apex_migration_bucket.bucket_arn,
          "${module.apex_migration_bucket.bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:sts::754256621582:assumed-role/access-via-github/Tim97eng"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          module.apex_migration_bucket.bucket_arn,
          "${module.apex_migration_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

  depends_on = [module.apex_migration_bucket]
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
          module.apex_migration_bucket.bucket_arn,
          "${module.apex_migration_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

  depends_on = [module.apex_migration_bucket]
}

resource "aws_iam_policy" "rds_s3_policy" {
  name        = "apex-rds-s3-policy"
  description = "Policy to allow RDS to access the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:GetObjectVersion"
        ],
        Resource = [
          module.apex_migration_bucket.bucket_arn,
          "${module.apex_migration_bucket.bucket_arn}/*"
        ]
      }
    ]
  })

  depends_on = [module.apex_migration_bucket]
}

resource "aws_iam_role_policy_attachment" "rds_s3_role_attachment" {
  policy_arn = aws_iam_policy.rds_s3_policy.arn
  role       = aws_iam_role.apex_rds_s3_role.name
}

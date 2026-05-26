resource "aws_iam_role" "rds_s3_integration" {
  name = "apex-rds-s3-integration-role"

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


bucket_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = {
        AWS = [
          aws_iam_role.rds_s3_integration.arn
        ]
      }
      Action = [
        "s3:ListBucket"
      ]
      Resource = [
        "$${bucket_arn}"
      ]
    },
    {
      Effect = "Allow"
      Principal = {
        AWS = [
          aws_iam_role.rds_s3_integration.arn
        ]
      }
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = [
        "$${bucket_arn}/*"
      ]
    }
  ]
})

resource "aws_iam_role_policy_attachment" "rds_s3_attach" {
  role       = aws_iam_role.rds_s3_integration.name
  policy_arn = aws_iam_policy.rds_s3_access_policy.arn
}

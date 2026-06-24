# Glue crawler role

resource "aws_iam_role" "copilot_credits_dev_glue_role" {
  name = "copilot_credits_dev_glue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "copilot_credits_dev_glue_s3_policy" {
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  role = aws_iam_role.copilot_credits_dev_glue_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "${module.s3_bucket.bucket_arn}/*",
          module.s3_bucket.bucket_arn
        ]
      },
      {
        Sid    = "AthenaAccess",
        Effect = "Allow",
        Action = [
          "athena:GetDatabase",
          "athena:GetDataCatalog",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetTableMetadata",
          "athena:GetWorkGroup",
          "athena:ListDatabases",
          "athena:ListDataCatalogs",
          "athena:ListWorkGroups",
          "athena:ListTableMetadata",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution"
        ],
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "copilot_credits_dev_glue_service_role_attachment" {
  role       = aws_iam_role.copilot_credits_dev_glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}
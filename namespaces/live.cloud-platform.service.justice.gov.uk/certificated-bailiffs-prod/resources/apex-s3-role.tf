data "aws_iam_role" "rds_s3_integration" {
  name = "rds-s3-integration-role"
}

data "aws_iam_policy" "rds_s3_access_policy" {
  name = "rds-s3-access-policy"
}


resource "aws_iam_role_policy_attachment" "rds_s3_attach" {
  role       = data.aws_iam_role.rds_s3_integration.name
  policy_arn = data.aws_iam_policy.rds_s3_access_policy.arn
}

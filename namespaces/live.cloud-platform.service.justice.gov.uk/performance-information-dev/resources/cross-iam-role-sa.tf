# IAM policy granting the IRSA service-account role permission to query the
# external "moj-pis" data lake (Athena + Glue + S3) in the target AWS account.
#
# This policy is attached to the existing IRSA role created in irsa.tf via the
# module's `role_policy_arns` input. The target AWS account must also update the
# resource policies (e.g. the S3 bucket policy / Glue/Athena permissions) to
# trust this role's ARN. See:
# https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/access-cross-aws-resources-irsa-eks.html
data "aws_iam_policy_document" "cross_account_athena" {
  statement {
    sid    = "Athena"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",
      "athena:StopQueryExecution",
      "athena:GetWorkGroup",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "S3"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:AbortMultipartUpload",
    ]
    resources = [
      "arn:aws:s3:::moj-pis-bronze-output",
      "arn:aws:s3:::moj-pis-bronze-output/*",
    ]
  }

  statement {
    sid    = "Glue"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:BatchGetPartition",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cross_account_athena" {
  name   = "cloud-platform-${var.namespace}-athena"
  path   = "/cloud-platform/"
  policy = data.aws_iam_policy_document.cross_account_athena.json

  tags = {
    business-unit = var.business_unit
    application   = var.application
    is-production = var.is_production
    namespace     = var.namespace
  }
}

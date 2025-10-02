module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment_name}"
  role_policy_arns = {
    s3        = module.s3_bucket.irsa_policy_arn
    migration = aws_iam_policy.migration_policy.arn
    athena    = aws_iam_policy.athena_allow_irsa.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace # this is also used to attach your service account to your namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

# IRSA policy for service pod to run Athena + read/write inventory/results (mirrors audit)
data "aws_iam_policy_document" "athena_irsa" {
  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults",

      "s3:PutObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",

      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartition",
    ]
    resources = [
      aws_athena_workgroup.alfresco_queries.arn,
      "arn:aws:athena:eu-west-2:*:queryexecution/*",

      "arn:aws:glue:eu-west-2:*:catalog",
      aws_glue_catalog_database.alfresco_glue.arn,
      aws_glue_catalog_table.s3_inventory.arn,
      aws_glue_catalog_table.expected_keys.arn,

      module.s3_inventory_reports.bucket_arn,
      "${module.s3_inventory_reports.bucket_arn}/*",

      module.s3_bucket.bucket_arn, # (optional) allow reading content-bucket metrics if needed
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "athena_allow_irsa" {
  name        = "${var.namespace}-athena-read-write"
  path        = "/cloud-platform/"
  description = "IRSA policy to run Athena queries for S3 Inventory checker"
  policy      = data.aws_iam_policy_document.athena_irsa.json
}

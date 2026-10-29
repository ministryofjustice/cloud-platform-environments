data "aws_iam_policy_document" "query_logs" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = [
      "${module.address_matcher_query_logs_s3.bucket_arn}/*"
    ]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = [module.address_matcher_query_logs_s3.bucket_arn]
  }
}

resource "aws_iam_policy" "query_logs" {
  name   = "address-matcher-query-logs"
  policy = data.aws_iam_policy_document.query_logs.json
}

# Read-only access to the Analytical Platform pull bucket that holds the
# canonical lookup data (data-engineering-exports pull dataset
# "address-matcher-lookup-data"). Cross-account S3 requires a policy on BOTH
# sides: the AP-side bucket policy (managed via pull_arns) plus this identity
# policy on our CP role. Lets the pod copy the data into the CP lookup bucket.
data "aws_iam_policy_document" "lookup_data_source" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::mojap-address-matcher-lookup-data/*"]
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::mojap-address-matcher-lookup-data"]
  }
}

resource "aws_iam_policy" "lookup_data_source" {
  name   = "address-matcher-lookup-data-source"
  policy = data.aws_iam_policy_document.lookup_data_source.json
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "address-matcher-api-s3"
  namespace            = var.namespace

  role_policy_arns = {
    lookup_data        = module.address_matcher_lookup_data_s3.irsa_policy_arn
    lookup_data_source = aws_iam_policy.lookup_data_source.arn
    query_logs         = aws_iam_policy.query_logs.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

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

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "address-matcher-api-s3"
  namespace            = var.namespace

  role_policy_arns = {
    lookup_data = module.address_matcher_lookup_data_s3.irsa_policy_arn
    query_logs  = aws_iam_policy.query_logs.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

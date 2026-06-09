data "aws_iam_policy_document" "query_logs_write_only" {
  statement {
    actions = ["s3:PutObject"]
    resources = [
      "${module.address_matcher_query_logs_s3.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "query_logs_put_only" {
  name   = "address-matcher-query-logs-put-only"
  policy = data.aws_iam_policy_document.query_logs_put_only.json
}


data "aws_iam_policy_document" "query_logs_read_only" {
  statement {
    actions = ["s3:GetObject"]
    resources = [
      "${module.address_matcher_query_logs_s3.bucket_arn}/*"
    ]
  }

  statement {
    actions = ["s3:ListBucket"]
    resources = [
      module.address_matcher_query_logs_s3.bucket_arn
    ]
  }
}

resource "aws_iam_policy" "query_logs_read_only" {
  name   = "address-matcher-query-logs-read-only"
  policy = data.aws_iam_policy_document.query_logs_read_only.json
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "address-matcher-api-s3"
  namespace            = var.namespace

  role_policy_arns = {
    models           = module.address_matcher_models_s3.irsa_policy_arn
    lookup_data      = module.address_matcher_lookup_data_s3.irsa_policy_arn
    query_logs_write = aws_iam_policy.query_logs_write_only.arn
    query_logs_read  = aws_iam_policy.query_logs_read_only.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

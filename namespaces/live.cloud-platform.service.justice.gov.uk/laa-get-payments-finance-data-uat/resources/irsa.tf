module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "laa-get-payments-finance-data-uat-service"
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    ecr = module.ecr.irsa_policy_arn
    data_ecr = module.data_ecr.irsa_policy_arn
    s3_read_only = aws_iam_policy.service_read_only_s3.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "laa-get-payments-finance-data-uat-service-pod"
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    ecr = module.ecr.irsa_policy_arn
    data_ecr = module.data_ecr.irsa_policy_arn
    file_store = module.s3_bucket.irsa_policy_arn
    report_store = module.s3_bucket_report_store.irsa_policy_arn
    report_store_logging = module.s3_bucket_report_store_logging.irsa_policy_arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "service_read_only_s3" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [
      module.s3_bucket.bucket_arn,
      module.s3_bucket_report_store.bucket_arn
    ]
  }

  statement {
    actions   = ["s3:GetObject"]
    resources = [
      "${module.s3_bucket.bucket_arn}/*",
      "${module.s3_bucket_report_store.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "service_read_only_s3" {
  name   = "${var.namespace}-service-read-only-s3"
  policy = data.aws_iam_policy_document.service_read_only_s3.json
}
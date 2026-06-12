module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "migration-link-exchange-sa"
  namespace            = var.namespace

  role_policy_arns = {
    s3  = aws_iam_policy.migration_link_exchange_prod_s3_restricted_access.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "migration_link_exchange_prod_s3_restricted_access" {
  # List & location for the S3 bucket.
  statement {
    actions = [ 
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [ 
      module.s3_bucket.bucket_arn
    ]
  }
  # Permissions to read specific paths.
  statement {
    actions = [
      "s3:GetObject"
    ]
    resources = [ 
        "${module.s3_bucket.bucket_arn}/build-output/*"
    ]
  }
}

resource "aws_iam_policy" "migration_link_exchange_prod_s3_restricted_access" {
  name   = "migration_link_exchange_prod_s3_restricted_access"
  policy = data.aws_iam_policy_document.migration_link_exchange_prod_s3_restricted_access.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    rolearn        = module.irsa.role_arn
    serviceaccount = module.irsa.service_account.name
  }
}

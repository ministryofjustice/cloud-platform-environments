
module "analytical-platform" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = {
    analytical-platform = aws_iam_policy.analytical-platform.arn
  }
  service_account_name = "${var.namespace}-analytical-platform"
  # Tags
  business_unit          = var.business_unit
  team_name              = var.team_name
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "analytical_platform_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "bucket-policy" {
  statement {
    actions = [
      "s3:ListBucket"
    ]
    resources = [
      module.analytical_platform_s3_bucket.bucket_arn
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "${module.analytical_platform_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "analytical-platform" {
  name   = "${var.namespace}-analytical-platform"
  policy = data.aws_iam_policy_document.bucket-policy.json
  # NB: IAM policy name must be unique within Cloud Platform

  tags = {
    business_unit          = var.business_unit
    team_name              = var.team_name
    application            = var.application
    is_production          = var.is_production
    namespace              = var.namespace
    environment_name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
  }
}


resource "kubernetes_secret" "analytical-platform" {
  metadata {
    name      = "analytical-platform-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.analytical_platform_s3_bucket.bucket_arn
    bucket_name = module.analytical_platform_s3_bucket.bucket_name
  }
}

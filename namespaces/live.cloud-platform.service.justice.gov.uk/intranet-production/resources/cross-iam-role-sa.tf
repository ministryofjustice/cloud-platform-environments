module "cross_irsa" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  business_unit          = var.business_unit
  application            = var.application
  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "${var.namespace}-cross-service"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  role_policy_arns       = { s3 = aws_iam_policy.intranet_production_s3.arn }
}

data "aws_iam_policy_document" "intranet_production_s3" {
  # List & location for source & destination S3 bucket.
  statement {
    actions = [ 
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [ 
      module.s3_bucket.bucket_arn,
      "arn:aws:s3:::intranet2-prod-storage-msxbyjnl9m83"
    ]
  }
  # Permissions on source S3 bucket contents. 
  statement {
    actions = [ 
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging"
    ]
    resources = [ "arn:aws:s3:::intranet2-prod-storage-msxbyjnl9m83/*" ]
  }
  # Permissions on destination S3 bucket contents. 
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [ "${module.s3_bucket.bucket_arn}/*" ]
  }
}

resource "aws_iam_policy" "intranet_production_s3" {
  name   = "intranet_production_s3"
  policy = data.aws_iam_policy_document.intranet_production_s3.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "cross_irsa" {
  metadata {
    name      = "cross-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.cross_irsa.role_name
    rolearn        = module.cross_irsa.role_arn
    serviceaccount = module.cross_irsa.service_account.name
  }
}

# set up the service pod
module "cross_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.cross_irsa.service_account.name # this uses the service account name from the irsa module
}

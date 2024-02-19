module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-service-pod"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3                     = module.evidencelibrary_document_s3_bucket.irsa_policy_arn,
    rds                    = module.evidencelibrary_rds.irsa_policy_arn,
    s3_cross_bucket_policy = aws_iam_policy.s3_cross_bucket_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "s3_cross_bucket_policy" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-3d68a6f5cf412bd505c3c064523d0de0", # staging
      "arn:aws:s3:::cloud-platform-2a3086cd6da8b757b070e15e4f222936"  # test
    ]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-3d68a6f5cf412bd505c3c064523d0de0/*", # staging
      "arn:aws:s3:::cloud-platform-2a3086cd6da8b757b070e15e4f222936/*"  # test
    ]
  }
}

resource "aws_iam_policy" "s3_cross_bucket_policy" {
  name   = "evidencelibrary-staging-s3-cross-bucket-policy"
  policy = data.aws_iam_policy_document.s3_cross_bucket_policy.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}
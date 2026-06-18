module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hale-platform-prod-service"
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3                     = module.s3_bucket.irsa_policy_arn,
    s3_cross_bucket_policy = aws_iam_policy.s3_cross_bucket_policy.arn,
    ecr                    = module.ecr_credentials.irsa_policy_arn,
    ecr2                   = module.ecr_feed_parser.irsa_policy_arn,
    rds                    = module.rds.irsa_policy_arn,
    cloudfront             = aws_iam_policy.cloudfront_access_policy.arn,
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
  # staging, dev, demo
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-62f8d0a2889981191680c9ad82b1f8cf",
      "arn:aws:s3:::cloud-platform-e8ef9051087439cca56bf9caa26d0a3f",
      "arn:aws:s3:::cloud-platform-f90b68639e12a88881c27434d72d6119",
    ]
  }
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:GetObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-62f8d0a2889981191680c9ad82b1f8cf/*",
      "arn:aws:s3:::cloud-platform-e8ef9051087439cca56bf9caa26d0a3f/*",
      "arn:aws:s3:::cloud-platform-f90b68639e12a88881c27434d72d6119/*",
      # Temporarily allow GetObjectTagging in own (prod) bucket on the service pod.
      # Required for a Justice migration step.
      "arn:aws:s3:::cloud-platform-e218f50a4812967ba1215eaecede923f/*"
    ]
  }

  # Read-only access to the legacy single-site justice bucket for migration
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-f5c06609f4885d0d5fb9e974c850af64",
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-f5c06609f4885d0d5fb9e974c850af64/*",
    ]
  }
}

# Policy allowing us to move objects between namespace buckets and external AWS accounts
resource "aws_iam_policy" "s3_cross_bucket_policy" {
  name   = "hale-platform-prod-s3-cross-bucket-policy"
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

data "aws_iam_policy_document" "cloudfront_access_policy" {
  statement {
    effect = "Allow"
    actions = [
      "cloudfront:GetDistribution",
      "cloudfront:ListDistributions",
      "cloudfront:CreateInvalidation",
      "cloudfront:GetInvalidation",
      "cloudfront:ListInvalidations",
      "cloudfront:GetCachePolicy"
    ]
    resources = [
      "*"
    ]
  }
}


resource "aws_iam_policy" "cloudfront_access_policy" {
  name   = "hale-platform-prod-cloudfront-access-policy"
  policy = data.aws_iam_policy_document.cloudfront_access_policy.json


  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}


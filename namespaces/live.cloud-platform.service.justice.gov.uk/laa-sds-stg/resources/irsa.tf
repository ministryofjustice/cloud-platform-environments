module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0" # use the latest release

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "laa-sds-serviceaccount-${var.environment}"
  role_policy_arns = merge(
    {
      dynamodb             = aws_iam_policy.auditdb_policy.arn,
      dynamodb-event-audit = aws_iam_policy.event_auditdb_policy.arn,
      s3                   = module.laa_sds_equiniti.irsa_policy_arn,
      s3_versioning        = aws_iam_policy.s3_versioning_policy.arn
    },
    { for name, module in module.s3_buckets : name => module.irsa_policy_arn }
  )

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "cross-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0" # use the latest release

  eks_cluster_name = var.eks_cluster_name

  service_account_name = "laa-sds-serviceaccount-migration-${var.environment}"
  role_policy_arns       = { s3 = aws_iam_policy.s3_migrate_policy.arn }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "s3_versioning_policy" {
  # Required to call boto3's list_object_versions()
  statement {
    actions = ["s3:ListBucketVersions"]
    resources = [
      for name in var.bucket_names :
      "arn:aws:s3:::${name}-${var.environment}"
    ]
  }

  # Required to get/hard-delete specific object versions
  statement {
    actions = ["s3:GetObjectVersion", "s3:DeleteObjectVersion"]
    resources = [
      for name in var.bucket_names :
      "arn:aws:s3:::${name}-${var.environment}/*"
    ]
  }
}
resource "aws_iam_policy" "s3_versioning_policy" {
  name   = "s3_versioning_policy_${var.environment}"
  policy = data.aws_iam_policy_document.s3_versioning_policy.json
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

data "aws_iam_policy_document" "s3_migrate_policy" {
  # List & location for source & destination S3 bucket.
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      module.laa_sds_equiniti.bucket_arn,
      "arn:aws:s3:::cloud-platform-b988a47b75caeabd901c79c3565f642a"
    ]
  }
  # Permissions on source S3 bucket contents.
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging"
    ]
    resources = [ "arn:aws:s3:::cloud-platform-b988a47b75caeabd901c79c3565f642a/*" ]   # take note of trailing /* here
  }
  # Permissions on destination S3 bucket contents.
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [ "${module.laa_sds_equiniti.bucket_arn}/*" ]
  }
}

resource "aws_iam_policy" "s3_migrate_policy" {
  name   = "s3_migrate_policy_${var.environment}"
  policy = data.aws_iam_policy_document.s3_migrate_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

# store irsa rolearn in k8s secret for retrieving to provide within source bucket policy
resource "kubernetes_secret" "cross_irsa" {
  metadata {
    name      = "cross-irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.cross-irsa.role_name
    rolearn        = module.cross-irsa.role_arn
    serviceaccount = module.cross-irsa.service_account.name
  }
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}

module "cross_irsa_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.cross-irsa.service_account.name # this uses the service account name from the irsa module
}
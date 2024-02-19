module "reporting_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-interventions-to-ndmis-s3"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    s3 = aws_iam_policy.ndmis_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "ndmis_policy" {
  name   = "${var.namespace}-ndmis-policy"
  policy = data.aws_iam_policy_document.reporting_access.json
}

locals {
  bucket_name   = "eu-west-2-delius-prod-dfi-extracts"
  bucket_prefix = "dfinterventions/dfi"
}

data "aws_iam_policy_document" "reporting_access" {
  statement {
    sid = "AllowDataExportUserToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowDataExportUserToWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/${local.bucket_prefix}/*",
      "arn:aws:s3:::${local.bucket_name}/${local.bucket_prefix}/"
    ]
  }
}

resource "random_id" "reporting_user_id" {
  byte_length = 16
}

resource "aws_iam_user" "reporting_user" {
  name = "reporting-s3-bucket-user-${random_id.reporting_user_id.hex}"
  path = "/system/reporting-s3-bucket-user/"
}

resource "aws_iam_access_key" "reporting_user" {
  user = aws_iam_user.reporting_user.name
}

resource "aws_iam_user_policy" "reporting_user_policy" {
  name   = "${var.namespace}-reporting-s3-snapshots"
  policy = data.aws_iam_policy_document.reporting_access.json
  user   = aws_iam_user.reporting_user.name
}

resource "kubernetes_secret" "reporting_aws_secret" {
  metadata {
    name      = "reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://${local.bucket_name}/${local.bucket_prefix}"
    user_arn           = aws_iam_user.reporting_user.arn
    access_key_id      = aws_iam_access_key.reporting_user.id
    secret_access_key  = aws_iam_access_key.reporting_user.secret
    bucket_name        = local.bucket_name
  }
}

resource "kubernetes_secret" "reporting_irsa" {
  metadata {
    name      = "to-ndmis-s3-irsa"
    namespace = var.namespace
  }

  data = {
    role           = module.reporting_irsa.role_name
    serviceaccount = module.reporting_irsa.service_account.name
  }
}

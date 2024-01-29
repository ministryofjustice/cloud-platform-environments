module "ap_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  #role_policy_arns = [aws_iam_policy.ap_policy.arn]
  #service_account  = "hmpps-remand-and-sentencing-to-ap-s3"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hmpps-remand-and-sentencing-to-ap-s3"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    s3 = aws_iam_policy.ap_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

}

# set up the service pod
module "ap_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.ap_irsa.service_account.name # this uses the service account name from the irsa module
}

resource "aws_iam_policy" "ap_policy" {
  name   = "${var.namespace}-ap-policy"
  policy = data.aws_iam_policy_document.ap_access.json
}

data "aws_iam_policy_document" "ap_access" {
  statement {
    sid = "AllowRdsExportUserToListS3Buckets"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::moj-reg-dev"
    ]
  }

  statement {
    sid = "AllowRdsExportUserWriteToS3"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::moj-reg-dev/landing/hmpps-remand-and-sentencing-dev/*",
      "arn:aws:s3:::moj-reg-dev/landing/hmpps-remand-and-sentencing-dev/"
    ]
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "ap-s3-bucket-user-${random_id.id.hex}"
  path = "/system/ap-s3-bucket-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "${var.namespace}-ap-s3-snapshots"
  policy = data.aws_iam_policy_document.ap_access.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://moj-reg-dev/landing/hmpps-remand-and-sentencing-dev/"
    user_arn           = aws_iam_user.user.arn
  }
}

resource "kubernetes_secret" "ap_irsa" {
  metadata {
    name      = "to-ap-s3-irsa"
    namespace = var.namespace
  }

  data = {
    role           = module.ap_irsa.role_name
    serviceaccount = module.ap_irsa.service_account.name
  }
}

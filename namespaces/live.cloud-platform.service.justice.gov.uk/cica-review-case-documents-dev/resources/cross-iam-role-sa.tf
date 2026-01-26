module "irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  team_name              = var.team_name

  service_account_name = "${var.namespace}-to-cica-s3"
  role_policy_arns = {
    cica_s3 = aws_iam_policy.access_cica_s3.arn
  }
}

data "aws_iam_policy_document" "access_cica_s3" {
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::589450497571:role/CaseReviewDocsCPNamespaceS3Access"
    ]
  }

  statement {
    sid    = "AllowS3Read"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::document-page-bucket",
      "arn:aws:s3:::document-page-bucket/*"
    ]
  }

  statement {
    sid    = "AllowKMSDecrypt"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      "arn:aws:kms:eu-west-2:589450497571:key/64cd9108-3ab8-4179-a7aa-850198da4afd"
    ]
  }
}

resource "aws_iam_policy" "access_cica_s3" {
  name   = "${var.namespace}-access-cica-s3-policy"
  policy = data.aws_iam_policy_document.access_cica_s3.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    environment_name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
  }

}
resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}

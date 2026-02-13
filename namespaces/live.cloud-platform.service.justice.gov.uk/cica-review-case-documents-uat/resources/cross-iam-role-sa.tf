
module "irsa-cica-s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "irsa-cica-s3"
  namespace             = var.namespace

  role_policy_arns = {
    s3kms = aws_iam_policy.cica_s3_kms_access.arn
  }

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


data "aws_iam_policy_document" "cica_s3_kms_access" {
  statement {
    sid    = "AllowS3GetObject"
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::uat-documentsearch-kta-bucket",
      "arn:aws:s3:::uat-documentsearch-kta-bucket/*"
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
      "arn:aws:kms:eu-west-2:621815915101:key/af68391f-0be7-4a9b-81a2-4e89bcc7025b"
    ]
  }
}

resource "aws_iam_policy" "cica_s3_kms_access" {
  name   = "${var.namespace}-cica-s3-kms-access-policy"
  policy = data.aws_iam_policy_document.cica_s3_kms_access.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    environment_name       = var.environment
    owner                  = var.team_name
    infrastructure_support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa_cica_s3" {
  metadata {
    name      = "irsa-cica-s3-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa-cica-s3.role_name
    serviceaccount = module.irsa-cica-s3.service_account.name
    rolearn        = module.irsa-cica-s3.role_arn
  }
}

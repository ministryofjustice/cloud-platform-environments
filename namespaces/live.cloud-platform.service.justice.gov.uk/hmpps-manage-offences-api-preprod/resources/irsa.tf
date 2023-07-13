locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-manage-offences-api-preprod"
  role_policy_arns = merge(
    { "s3" = aws_iam_policy.hmpps_manage_offences_api_preprod_ap_policy.arn },
    local.sns_policies
  )
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_iam_policy_document" "hmpps_manage_offences_api_preprod_ap_policy" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::mojap-manage-offences",
    ]
  }
  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::mojap-manage-offences/*"
    ]
  }
}
resource "aws_iam_policy" "hmpps_manage_offences_api_preprod_ap_policy" {
  name   = "hmpps_manage_offences_api_preprod_ap_policy"
  policy = data.aws_iam_policy_document.hmpps_manage_offences_api_preprod_ap_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "manage-offences-ap-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn = "arn:aws:s3:::mojap-manage-offences"
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
    rolearn        = module.irsa.role_arn
  }
}


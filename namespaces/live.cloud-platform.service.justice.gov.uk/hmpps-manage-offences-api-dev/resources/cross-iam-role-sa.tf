module "irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.hmpps_manage_offences_api_dev_ap_policy.arn]
}
data "aws_iam_policy_document" "hmpps_manage_offences_api_dev_ap_policy" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:GetObject*",
    ]
    resources = [
      "arn:aws:s3:::alpha-lookup-cjsq/lookup_offence_raw/data/*",
      "arn:aws:s3:::mojap-derived-tables/prod/models/domain_name=general/database_name=lookup_offence_v2/*"
    ]
  }
}
resource "aws_iam_policy" "hmpps_manage_offences_api_dev_ap_policy" {
  name   = "hmpps_manage_offences_api_dev_ap_policy"
  policy = data.aws_iam_policy_document.hmpps_manage_offences_api_dev_ap_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}
resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "hmpps-manage-offences-api-dev"
  }
  data = {
    role           = module.irsa.aws_iam_role_name
    serviceaccount = module.irsa.service_account_name.name
  }
}

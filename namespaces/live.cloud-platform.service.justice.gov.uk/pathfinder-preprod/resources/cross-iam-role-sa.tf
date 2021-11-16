module "irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.0.2"
  namespace        = "pathfinder-preprod"
  role_policy_arns = [aws_iam_policy.pathfinder_preprod_ap_policy.arn]
  service_account  = "to-ap-s3-service-account"
}
data "aws_iam_policy_document" "pathfinder_preprod_ap_policy" {
  # "api" policy statements for the namespace
  # allows direct access to "landing" S3 bucket
  statement {
    actions   = [
      "s3:PutObject",
      "s3:PutObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::mojap-land/hmpps/pathfinder/preprod/*",
    ]
  }
}
resource "aws_iam_policy" "pathfinder_preprod_ap_policy" {
  name   = "pathfinder_preprod_ap_policy"
  policy = data.aws_iam_policy_document.pathfinder_preprod_ap_policy.json
}
variable "pathfinder-preprod-tags" {
  type    = map(string)
  default = {
    business-unit          = var.business-unit
    application            = var.application
    is-production          = var.is-production
    environment-name       = var.environment-name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure-support
  }
}
resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = "pathfinder-preprod"
  }
  data = {
    role           = module.irsa.aws_iam_role_name
    serviceaccount = module.irsa.service_account_name
  }
}

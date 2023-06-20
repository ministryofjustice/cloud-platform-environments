module "irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.cjs_dashboard_demo_ap_policy.arn]
}
data "aws_iam_policy_document" "cjs_dashboard_demo_ap_policy" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::mojap-alpha-cjs-scorecard",
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "arn:aws:s3:::mojap-alpha-cjs-scorecard/*"
    ]
  }
}
resource "aws_iam_policy" "cjs_dashboard_demo_ap_policy" {
  name   = "cjs_dashboard_demo_ap_policy"
  policy = data.aws_iam_policy_document.cjs_dashboard_demo_ap_policy.json

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
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.aws_iam_role_name
    serviceaccount = module.irsa.service_account_name.name
    rolearn        = module.irsa.aws_iam_role_arn
  }
}

resource "random_id" "cjs-dashboard-demo-ap-id" {
  byte_length = 16
}

resource "aws_iam_user" "cjs_dashboard_demo_ap_user" {
  name = "ap-s3-user-${random_id.cjs-dashboard-demo-ap-id.hex}"
  path = "/system/manage-offences-api-ap-s3-bucket-user/"
}

resource "aws_iam_access_key" "cjs_dashboard_demo_ap_user" {
  user = aws_iam_user.cjs_dashboard_demo_ap_user.name
}

resource "aws_iam_user_policy" "cjs_dashboard_demo_ap_policy" {
  name   = "${var.namespace}-ap-s3"
  policy = data.aws_iam_policy_document.cjs_dashboard_demo_ap_policy.json
  user   = aws_iam_user.cjs_dashboard_demo_ap_user.name
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "cjs-dashboard-demo-ap-s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn         = "arn:aws:s3:::alpha-cjs-scorecard"
    user_arn           = aws_iam_user.cjs_dashboard_demo_ap_user.arn
    access_key_id      = aws_iam_access_key.cjs_dashboard_demo_ap_user.id
    secret_access_key  = aws_iam_access_key.cjs_dashboard_demo_ap_user.secret
  }
}

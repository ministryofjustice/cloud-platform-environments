data "aws_eks_cluster" "eks_cluster" {
  name = var.eks_cluster_name
}

module "datahub_frontend_assumable_role" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.13.0"
  create_role                   = true
  role_name                     = "${var.datahub-frontend-sa}-${var.eks_cluster_name}"
  provider_url                  = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
  role_policy_arns              = [aws_iam_policy.data_platform_datahub.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.datahub-frontend-sa}"]
}

# module "datahub_gms_assumable_role" {
#   source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
#   version                       = "5.13.0"
#   create_role                   = true
#   role_name                     = "${var.datahub-gms-sa}-${var.eks_cluster_name}"
#   provider_url                  = data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
#   role_policy_arns              = [aws_iam_policy.data_platform_datahub.arn]
#   oidc_fully_qualified_subjects = ["system:serviceaccount:${var.namespace}:${var.datahub-gms-sa}"]
# }

data "aws_iam_policy_document" "data_platform_datahub" {
  # AssumeRole permissions for S3 access in
  # data-platform-development mod-platform acct.
  statement {
    actions = [
      "sts:AssumeRole"
    ]
    resources = [
      "arn:aws:iam::${var.mp_account}:role/DatahubProductS3AccessRole",
    ]
  }
}
resource "aws_iam_policy" "data_platform_datahub" {
  name   = "${var.namespace}-datahub-assume-role-policy"
  policy = data.aws_iam_policy_document.data_platform_datahub.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.github_owner
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "datahub_frontend_role" {
  metadata {
    name      = "datahub-frontend-role"
    namespace = var.namespace
  }
  data = {
    role = module.datahub_frontend_assumable_role.iam_role_name
    arn  = module.datahub_frontend_assumable_role.iam_role_arn
  }
}

# resource "kubernetes_secret" "datahub_gms_role" {
#   metadata {
#     name      = "datahub-gms-role"
#     namespace = var.namespace
#   }
#   data = {
#     role = module.datahub_gms_assumable_role.iam_role_name
#     arn  = module.datahub_gms_assumable_role.iam_role_arn
#   }
# }
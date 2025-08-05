data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

data "aws_eks_cluster" "eks_cluster" {
name = var.eks_cluster_name
}

module "iam_assumable_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  allow_self_assume_role     = false
  assume_role_condition_test = "StringEquals"
  create_role                = true
  force_detach_policies      = true
  role_name                  = "${var.namespace}-live"
  role_policy_arns = {
    dynamodb                = module.dynamodb-cluster.irsa_policy_arn
    dynamodb_prod           = module.dynamodb-fci-prod.irsa_policy_arn
    xaccounts3              = aws_iam_policy.access_ap_s3_policy.arn
  }

  oidc_providers = {
    (data.aws_eks_cluster.eks_cluster.name) : {
      provider_arn               = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer, "https://", "")}"
      namespace_service_accounts = ["${var.namespace}:fraud-and-corruption-insights-prod-sa"]
    }
  }

  tags = {
    namespace = var.namespace
  }
}
